module Orchestration::DHCP
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :dhcp_conflict_detected?, :unless => :skip_orchestration?
    after_validation :queue_dhcp
    before_destroy :queue_dhcp_destroy
    register_rebuild(:rebuild_dhcp, N_('DHCP'))
  end

  def dhcp_ready?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    #
    # The subnet boot mode is ignored as DHCP can be required for PXE or image provisioning
    # steps, while boot mode can be used in templates later.
    (host.nil? || host.managed?) && managed? && hostname.present? && mac_available? &&
      SETTINGS[:unattended] && (!provision? || operatingsystem.present?)
  end

  def dhcp?
    dhcp_ready? && ip_available? && subnet.present? && subnet.dhcp?
  end

  def dhcp6?
    dhcp_ready? && ip6_available? && subnet6.present? && subnet6.dhcp?
  end

  def rebuild_dhcp
    unless any_dhcp?
      logger.info "DHCP not supported for #{name} (#{ip}/#{ip6}) skipping orchestration rebuild"
      return true
    end

    results = {}

    DhcpInterface::DHCP_RECORD_TYPES.each do |record_type|
      next unless dhcp_feasible?(record_type)
      del_dhcp_record_safe(record_type)
      results[record_type] = recreate_dhcp_record_safe(record_type)
    end

    results.values.all?
  end

  private

  # returns a hash of dhcp record settings
  def dhcp_attrs
    raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?
    dhcp_attr = {
      :name => name,
      :hostname => hostname,
      :ip => ip,
      :mac => mac,
      :proxy => subnet.dhcp_proxy,
      :network => subnet.network
    }

    if provision?
      dhcp_attr.merge!({:filename => operatingsystem.boot_filename(self), :nextServer => boot_server})
      if jumpstart?
        jumpstart_arguments = os.jumpstart_params self.host, model.vendor_class
        dhcp_attr.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      end
    end

    dhcp_attr
  end

  def queue_dhcp
    return unless can_queue_dhcp?
    queue_remove_dhcp_conflicts
    new_record? ? queue_dhcp_create : queue_dhcp_update
  end

  def queue_dhcp_create
    logger.debug "Scheduling new DHCP reservations for #{self}"
    DhcpInterface::DHCP_RECORD_TYPES.each do |record_type|
      queue.create(:name   => _("Create %{type} Settings for %{host}") % {:host => self, :type => dhcp_class(record_type).human}, :priority => 10,
                   :action => [self, :set_dhcp_record, record_type]) if dhcp_feasible?(record_type)
    end
  end

  def queue_dhcp_update
    return unless dhcp_update_required?
    logger.debug("Detected a changed required for DHCP record")

    DhcpInterface::DHCP_RECORD_TYPES.each do |record_type|
      queue.create(:name   => _("Remove %{type} Settings for %{host}") % {:host => self, :type => dhcp_class(record_type).human}, :priority => 5,
                   :action => [old, :del_dhcp_record, record_type]) if old.dhcp_feasible?(record_type)
      queue.create(:name   => _("Create %{type} Settings for %{host}") % {:host => self, :type => dhcp_class(record_type).human}, :priority => 9,
                   :action => [self, :set_dhcp_record, record_type]) if dhcp_feasible?(record_type)
    end
  end

  def queue_dhcp_destroy
    return unless (any_dhcp?) && errors.empty?
    DhcpInterface::DHCP_RECORD_TYPES.each do |record_type|
      queue.create(:name   => _("Remove %{type} Settings for %{host}") % {:host => self, :type => dhcp_class(record_type).human}, :priority => 5,
                   :action => [self, :del_dhcp_record, record_type]) if dhcp_feasible?(record_type)
    end
    true
  end

  def queue_remove_dhcp_conflicts
    return if !(dhcp? || dhcp6?) || !overwrite?

    logger.debug "Scheduling DHCP conflicts removal"
    DhcpInterface::DHCP_RECORD_TYPES.each do |record_type|
      queue.create(:name   => _("%{type} conflicts removal for %{host}") % {:host => self, :type => dhcp_class(record_type).human}, :priority => 5,
                   :action => [self, :del_conflicting_dhcp_record, record_type]) if dhcp_feasible?(record_type)
    end
  end

  def dhcp_conflict_detected?
    # we can't do any dhcp based validations when our MAC address is defined afterwards (e.g. in vm creation)
    return false if mac.blank? || hostname.blank?
    return false unless any_dhcp?

    DhcpInterface::DHCP_RECORD_TYPES.each do |record_type|
      if dhcp_record(record_type) && dhcp_record(record_type).conflicting? && (!overwrite?)
        failure(_("%{type} records %{records} already exists") % { :records => dhcp_record(record_type).conflicts.to_sentence, :type => dhcp_class(record_type).human}, nil, :conflict)
        return true
      end
    end
    false
  end

  # TODO: Fixme v6
  # do we need to update our dhcp reservations
  def dhcp_update_required?
    # IP Address / name changed, or 'rebuild' action is triggered and DHCP record on the smart proxy is not present/identical.
    return true if ((old.ip != ip) || (old.hostname != hostname) || (old.mac != mac) || (old.subnet != subnet) ||
                    (!old.build? && build? && !dhcp_record(:dhcp).valid?))
    # Handle jumpstart
    #TODO, abstract this way once interfaces are fully used
    if self.is_a?(Host::Base) && jumpstart?
      if !old.build? || (old.medium != medium || old.arch != arch) ||
          (os && old.os && (old.os.name != os.name || old.os != os))
        return true
      end
    end
    false
  end

  def can_queue_dhcp?
    (dhcp? || (old && old.dhcp?) || dhcp6? || (old && old.dhcp6?)) && orchestration_errors?
  end

  def any_dhcp?
    dhcp? || dhcp6?
  end
end
