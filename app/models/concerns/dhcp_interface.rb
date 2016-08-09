module DhcpInterface
  extend ActiveSupport::Concern

  DHCP_RECORD_TYPES = [:dhcp, :dhcp6, :sparc]

  def dhcp_record(type)
    validate_dhcp_record_type(type)

    record = get_dhcp_record(type)
    return record if record.present?

    return unless dhcp_feasible?(type)

    handle_validation_errors do
      store_dhcp_record(type, dhcp_class(type).new(send(:"#{type}_record_attrs")))
    end
  end

  protected

  def dhcp_feasible?(type)
    validate_dhcp_record_type(type)

    case type
    when :dhcp
      dhcp? && !jumpstart?
    when :sparc
      dhcp? && provision? && jumpstart?
    when :dhcp6
      dhcp6?
    end
  end

  def recreate_dhcp_record_safe(type)
    set_dhcp_record(type)
  rescue => e
    Foreman::Logging.exception "Failed to rebuild DHCP record for #{name} (#{ip}/#{ip6})", e, :level => :error
    false
  end

  def set_dhcp_record(type)
    dhcp_record(type).create
  end

  def del_dhcp_record(type)
    dhcp_record(type).destroy
  end

  def del_conflicting_dhcp_record(type)
    dhcp_record(type).conflicts.each { |c| c.destroy }
  end

  def del_dhcp_record_safe(type)
    return unless dhcp_record(type).present?
    del_dhcp_record(type)
  rescue => e
    Foreman::Logging.exception "Proxy failed to delete DHCP #{type}_record for #{name} (#{ip}/#{ip6})", e, :level => :error
  end

  # FIXME
  # where are we booting from
  def boot_server
    # if we don't manage tftp at all, we dont create a next-server entry.
    return unless tftp?

    # first try to ask our TFTP server for its boot server
    bs = tftp.bootServer
    # if that failed, trying to guess out tftp next server based on the smart proxy hostname
    bs ||= URI.parse(subnet.tftp.url).host
    # now convert it into an ip address (see http://theforeman.org/issues/show/1381)
    ip = to_ip_address(bs) if bs.present?
    return ip unless ip.nil?

    failure _("Unable to determine the host's boot server. The DHCP smart proxy failed to provide this information and this subnet is not provided with TFTP services.")
  rescue => e
    failure _("failed to detect boot server: %s") % e, e
  end

  private

  def dhcp_class(type)
    validate_dhcp_record_type(type)
    "Net::DHCP::#{type.upcase}Record".constantize
  end

  def get_dhcp_record(type)
    instance_variable_get("@#{type}_record")
  end

  def store_dhcp_record(type, value)
    instance_variable_set("@#{type}_record", value)
  end

  def validate_dhcp_record_type(type)
    raise ::Foreman::Exception.new(N_("%s is not a valid DHCP record type"), type) unless DHCP_RECORD_TYPES.include?(type)
  end

  def common_dhcp_record_attrs
    dhcp_attr = {
      :name => name,
      :hostname => hostname,
      :mac => mac
    }

    if provision?
      dhcp_attr.merge!({:filename => operatingsystem.boot_filename(self), :nextServer => boot_server})
    end

    dhcp_attr
  end

  def dhcp_record_attrs
    raise ::Foreman::Exception.new(N_('DHCP not supported for this NIC')) unless dhcp?
    common_dhcp_record_attrs.merge(
      {
        :ip => ip,
        :proxy => subnet.dhcp_proxy,
        :network => subnet.network
      }
    )
  end

  def sparc_record_attrs
    jumpstart_arguments = os.jumpstart_params(self.host, model.vendor_class)
    dhcp_record_attrs.merge! jumpstart_arguments unless jumpstart_arguments.empty?
  end

  def dhcp6_record_attrs
    raise ::Foreman::Exception.new(N_("DHCPv6 not supported for this NIC")) unless dhcp6?
    common_dhcp_record_attrs.merge(
      {
        :ip6 => ip6,
        :proxy => subnet6.dhcp_proxy,
        :network => subnet6.network
      }
    )
  end
end
