require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    skip_without_unattended
    User.current = users(:one)
    disable_orchestration
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
  end

  def teardown
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
    User.current = nil
  end

  context 'host without dhcp' do
    let(:host) { FactoryGirl.build(:host) }

    test 'should not have dhcp and dhcpv6' do
      host = FactoryGirl.create(:host)
      assert_valid host
      refute host.dhcp?, 'host.dhcp? does not return false'
      refute host.dhcp6?, 'host.dhcp6? does not return false'
    end

    test 'unmanaged should not call methods after managed?' do
      Nic::Managed.any_instance.expects(:ip_available?).never
      assert_valid host
      refute host.dhcp?
      refute host.dhcp6?
    end

    test 'should skip dhcp rebuild' do
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp).never
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp6).never
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:sparc).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp6).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:sparc).never
      host.save!
      assert host.interfaces.first.rebuild_dhcp
    end
  end

  context 'host with ipv4 dhcp' do
    let(:compute_resource) { FactoryGirl.build(:libvirt_cr) }
    let(:libvirt_host) { FactoryGirl.build(:host, :with_dhcp_orchestration, :compute_resource => compute_resource) }
    let(:tftp_subnet) { FactoryGirl.build(:subnet_ipv4, :dhcp, :tftp) }
    let(:host) { FactoryGirl.build(:host, :managed, :with_dhcp_orchestration) }
    let(:tftp_subnet_host) { FactoryGirl.create(:host, :with_dhcp_orchestration, :with_tftp_orchestration, :subnet => tftp_subnet) }

    test 'should have dhcp and no dhcpv6' do
      assert_valid host
      assert host.dhcp?, 'host.dhcp? does not return true'
      refute host.dhcp6?, 'host.dhcp6? does not return false'
      assert_instance_of Net::DHCP::DHCPRecord, host.dhcp_record(:dhcp)
      assert_nil host.dhcp_record(:dhcp6)
      assert_equal host.name, host.dhcp_record(:dhcp).hostname
    end

    test 'bmc should have valid dhcp record' do
      bmc = FactoryGirl.build(:nic_bmc, :ip => '10.0.0.10', :name => 'bmc')
      bmc.host = host
      bmc.domain = domains(:mydomain)
      bmc.subnet = subnets(:five)
      assert bmc.dhcp?
      assert_equal "#{bmc.name}.#{bmc.domain.name}-#{bmc.mac}/#{bmc.ip}", bmc.dhcp_record(:dhcp).to_s
    end

    test 'should rebuild dhcp' do
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp)
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp6).never
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:sparc).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp6).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:sparc).never
      host.save!
      assert host.interfaces.first.rebuild_dhcp
    end

    test 'should fail with exception' do
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp)
      Nic::Managed.any_instance.expects(:set_dhcp_record).with(:dhcp).raises(StandardError, 'DHCP test failure')
      host.save!
      refute host.interfaces.first.rebuild_dhcp
    end

    test 'static boot mode still enables dhcp orchestration' do
      interface = FactoryGirl.build(:nic_managed, :ip => '10.0.0.10', :name => 'eth0:0')
      interface.host   = host
      interface.domain = domains(:mydomain)
      interface.subnet = FactoryGirl.build(:subnet_ipv4, :dhcp, :boot_mode => 'Static', :ipam => 'Internal DB')
      assert interface.dhcp?
    end

    test 'new host should create a dhcp reservation' do
      assert host.new_record?

      assert host.valid?
      assert_equal host.queue.items.count {|x| x.action[1] == :set_dhcp_record }, 1
      assert host.queue.items.select {|x| x.action[1] == :del_dhcp_record }.empty?
    end

    test 'provision interface DHCP records should contain filename/next-server attributes' do
      ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
      assert_equal 'pxelinux.0', tftp_subnet_host.provision_interface.dhcp_record(:dhcp).filename
      assert_equal '192.168.1.1', tftp_subnet_host.provision_interface.dhcp_record(:dhcp).nextServer
    end

    test "queue_dhcp doesn't fail when mac address is blank but provided by compute resource" do
      compute_resource.stubs(:provided_attributes).returns({:mac => :mac})
      interface = libvirt_host.interfaces.first
      interface.mac = nil
      interface.stubs(:dhcp? => true, :overwrite? => true)

      assert interface.send(:queue_dhcp)
    end

    test 'new host should create a BMC dhcp reservation' do
      host.name = 'dummy-123'
      assert host.new_record?
      host.interfaces_attributes = [{ :name => "dummy-bmc", :ip => host.ip.succ, :mac => "aa:bb:cd:cd:ee:ff",
                                   :subnet_id => host.subnet_id, :provider => 'IPMI', :type => 'Nic::BMC', :domain_id => host.domain_id}]
      assert host.valid?

      bmc = host.interfaces.detect { |i| i.name =~ /^dummy-bmc/ }

      primary_interface_tasks = host.queue.items.select { |t| t.action.first == host.primary_interface }
      interface_tasks = host.queue.items.select { |t| t.action.first == bmc }

      assert_equal 1, primary_interface_tasks.count { |t| t.action[1] == :set_dhcp_record }
      assert_empty primary_interface_tasks.select { |t| t.action[1] == :del_dhcp_record }
      assert_equal 1, interface_tasks.count { |t| t.action[1] == :set_dhcp_record }
      assert_empty interface_tasks.select { |t| t.action[1] == :del_dhcp_record }
    end

    test "new host with dhcp and no operating system should show correct validation on save" do
      host.operatingsystem = nil

      # If there was an exception due to accessing operating_system.boot_filename when operating_system is nil
      # this line would cause an error in the test
      refute_valid host
      assert_equal host.errors[:operatingsystem_id].first, "can't be blank"
    end

    test "dhcp_record should return nil for invalid mac" do
      host.interfaces = [FactoryGirl.build(:nic_primary_and_provision, :mac => "aaaaaa")]
      assert_nil host.dhcp_record(:dhcp)
    end
  end

  context 'an existing ipv4 only host with dhcp' do
    let(:host) { FactoryGirl.create(:host, :managed, :with_dhcp_orchestration) }

    test 'when an existing host change its ip address, its dhcp record should be updated' do
      host.ip = host.ip.succ
      assert_valid host
      # 1st is creation from factory, 2nd is triggered by h.valid?
      assert_equal 2, host.queue.items.count {|x| x.action == [ host.primary_interface, :set_dhcp_record, :dhcp ] }
      # and also one deletion (of original creation)
      assert_equal 1, host.primary_interface.queue.items.count {|x| x.action[1] == :del_dhcp_record }
    end

    test "when an existing host change its bmc ip address, its dhcp record should be updated" do
      as_admin do
        Nic::BMC.create!(:host_id => host.id, :mac => "da:aa:aa:ab:db:bb", :domain_id => host.domain_id,
                         :ip => host.ip.succ, :subnet_id => host.subnet_id, :name => "bmc-#{host}", :provider => 'IPMI')
      end
      host.reload
      bmc = host.interfaces.bmc.first
      bmc.ip = bmc.ip.succ
      assert_valid bmc
      assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc, :set_dhcp_record, :dhcp ] }
      assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc.old, :del_dhcp_record, :dhcp ] }
    end

    test "when an existing host change its mac address, its dhcp record should be updated" do
      host.mac = next_mac(host.mac)
      assert_valid host
      assert_equal 2, host.queue.items.count {|x| x.action == [ host.primary_interface, :set_dhcp_record, :dhcp ] }
      assert_equal 1, host.primary_interface.queue.items.count {|x| x.action[1] == :del_dhcp_record }
    end

    test "when an existing host trigger a 'rebuild', its dhcp record should be updated if no dhcp record is found" do
      Net::DHCP::DHCPRecord.any_instance.stubs(:valid?).returns(false)

      host.build = true

      assert_valid host
      assert_equal 2, host.queue.items.count {|x| x.action == [ host.primary_interface, :set_dhcp_record, :dhcp ] }
      assert_equal 1, host.primary_interface.queue.items.count {|x| x.action[1] == :del_dhcp_record }
    end

    test "when an existing host trigger a 'rebuild', its dhcp record should not be updated if valid dhcp record is found" do
      Net::DHCP::DHCPRecord.any_instance.stubs(:valid?).returns(true)

      host.build = true

      assert_valid host
      assert_equal 1, host.queue.items.count {|x| x.action == [ host.primary_interface, :set_dhcp_record, :dhcp ] }
      assert_equal 0, host.primary_interface.queue.items.count {|x| x.action[1] == :del_dhcp_record }
    end

    test 'when an existing host change its bmc mac address, its dhcp record should be updated' do
      as_admin do
        Nic::BMC.create! :host => host, :mac => "aa:aa:aa:ab:bd:bb", :ip => host.ip.succ, :domain => host.domain,
          :subnet => host.subnet, :name => "bmc1-#{host}", :provider => 'IPMI'
      end
      host.reload
      host.queue.clear
      bmc = host.interfaces.bmc.first
      bmc.mac = next_mac(bmc.mac)
      assert_valid host
      assert_valid bmc
      assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc, :set_dhcp_record, :dhcp ] }
      assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc.old, :del_dhcp_record, :dhcp ] }
    end

    test 'when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated' do
      host = FactoryGirl.create(:host, :with_dhcp_orchestration, :mac => "aa:aa:ad:ab:bb:cc")
      as_admin do
        Nic::BMC.create!(:host => host, :mac => "aa:aa:ad:ab:bb:bb", :domain => host.domain, :subnet => host.subnet,
                         :name => "bmc-it", :provider => 'IPMI', :ip => host.ip.succ)
      end
      host.reload
      host.mac = next_mac(host.mac)
      bmc = host.interfaces.bmc.first.reload
      refute bmc.new_record?
      bmc.mac = next_mac(bmc.mac)
      assert_valid host
      assert_valid bmc
      assert_equal 2, host.queue.items.count {|x| x.action == [ host.primary_interface, :set_dhcp_record, :dhcp ] }
      assert_equal 1, host.queue.items.count {|x| x.action[1] == :del_dhcp_record }
      assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc,     :set_dhcp_record, :dhcp ] }
      assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc.old, :del_dhcp_record, :dhcp ] }
    end
  end

  context 'host with jumpstart dhcp' do
    let(:host) do
      FactoryGirl.build(:host, :managed, :with_dhcp_orchestration,
                        :operatingsystem => operatingsystems(:solaris10),
                        :architecture => architectures(:sparc),
                        :medium => media(:solaris10),
                        :ptable => FactoryGirl.create(:ptable, :operatingsystem_ids => [operatingsystems(:solaris10).id]),
                        :model => FactoryGirl.create(:model, :vendor_class => 'Sun-Fire-V210'))
    end

    test 'DHCP record contains jumpstart attributes' do
      host.expects(:jumpstart?).at_least_once.returns(true)
      host.os.expects(:jumpstart_params).at_least_once.with(host, host.model.vendor_class).returns(:vendor => '<Sun-Fire-V210>')
      host.valid?
      dhcp = host.provision_interface.dhcp_record(:sparc)
      assert_instance_of Net::DHCP::SPARCRecord, dhcp
      assert_equal '<Sun-Fire-V210>', dhcp.vendor
    end

    test 'should rebuild dhcp' do
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp).never
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp6).never
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:sparc)
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp6).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:sparc).returns(true)
      host.save!
      assert host.interfaces.first.rebuild_dhcp
    end
  end

  context 'host with ipv6 dhcp' do
    let(:host) { FactoryGirl.build(:host, :managed, :with_dhcpv6_orchestration) }

    test 'should have no dhcp but dhcpv6' do
      assert_valid host
      refute host.dhcp?, 'host.dhcp? does not return false'
      assert host.dhcp6?, 'host.dhcp6? does not return true'
      assert host.provision_interface.send(:dhcp_feasible?, :dhcp6)
      assert_nil host.dhcp_record(:dhcp)
      assert_instance_of Net::DHCP::DHCP6Record, host.dhcp_record(:dhcp6)
      assert_equal host.name, host.dhcp_record(:dhcp6).hostname
    end

    test 'should rebuild dhcp' do
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp).never
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:dhcp6)
      Nic::Managed.any_instance.expects(:del_dhcp_record).with(:sparc).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp).never
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:dhcp6).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dhcp_record_safe).with(:sparc).never
      host.save!
      assert host.interfaces.first.rebuild_dhcp
    end
  end
end
