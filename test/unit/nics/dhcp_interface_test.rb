require 'test_helper'

class NicDhcpInterfaceTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  context '#dhcp_record' do
    setup do
      @host = FactoryGirl.build(:host)
      @nic = FactoryGirl.build(:nic_managed, :host => @host)
    end

    test 'should raise error on invalid type' do
      assert_raises Foreman::Exception do
        @nic.dhcp_record(:invalid)
      end
    end

    test 'should return stored dhcp_record' do
      record = stub()
      @nic.instance_variable_set('@dhcp_record', record)
      assert_equal record, @nic.dhcp_record(:dhcp)
    end

    test 'should return nil if dhcp is not feasible' do
      @nic.expects(:dhcp?).once.returns(false)
      assert_nil @nic.dhcp_record(:dhcp)
    end

    test 'should return and store dhcp_record' do
      stub = stub()
      Net::DHCP::DHCPRecord.expects(:new).with({}).once.returns(stub)
      @nic.expects(:dhcp?).once.returns(true)
      @nic.expects(:dhcp_record_attrs).once.returns({})
      record = @nic.dhcp_record(:dhcp)
      assert_equal stub, record
      assert_equal record, @nic.instance_variable_get('@dhcp_record')
    end
  end
end
