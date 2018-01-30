require 'test_helper'

class UnattendedControllerTest < ActionController::TestCase
  setup do
    Host::Managed.any_instance.stubs(:handle_ca).returns(true)
    as_admin do
      disable_orchestration # avoids dns errors
      ptable = FactoryBot.create(:ptable, :name => 'default',
                                  :operatingsystem_ids => [operatingsystems(:redhat).id])
      ptable_ubuntu = FactoryBot.create(:ptable, :ubuntu, :name => 'ubuntu default',
        :layout => 'd-i partman-auto/disk string /dev/sda\nd-i partman-auto/method string regular...',
                                         :operatingsystem_ids => [operatingsystems(:ubuntu1010).id])
      @org = FactoryBot.create(:organization, :ignore_types => ['ProvisioningTemplate'])
      @loc = FactoryBot.create(:location, :ignore_types => ['ProvisioningTemplate'])
      @rh_host = FactoryBot.create(:host, :managed, :with_dhcp_orchestration, :build => true,
                                    :operatingsystem => operatingsystems(:redhat),
                                    :ptable => ptable,
                                    :medium => media(:one),
                                    :architecture => architectures(:x86_64),
                                    :organization => @org,
                                    :location => @loc
                                   )
      @ub_host = FactoryBot.create(:host, :managed, :with_dhcp_orchestration, :build => true,
                                    :operatingsystem => operatingsystems(:ubuntu1010),
                                    :ptable => ptable_ubuntu,
                                    :medium => media(:ubuntu),
                                    :architecture => architectures(:x86_64),
                                    :organization => @org,
                                    :location => @loc
                                   )
      @host_with_template_subnet = FactoryBot.create(:host, :managed, :with_dhcp_orchestration, :with_tftp_subnet, :build => true,
                                    :operatingsystem => operatingsystems(:ubuntu1010),
                                    :ptable => ptable_ubuntu,
                                    :medium => media(:ubuntu),
                                    :architecture => architectures(:x86_64),
                                    :organization => @org,
                                    :location => @loc
                                   )
    end
  end

  test "should get a kickstart" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
  end

  test "should get a kickstart even if not using the first NIC" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "unused NIC"
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_3"] = "eth4 #{@rh_host.mac}"
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
  end

  test "should get a kickstart even if we are behind a loadbalancer" do
    @request.env["HTTP_X_FORWARDED_FOR"] = @rh_host.ip
    @request.env["REMOTE_ADDR"] = "127.0.0.1"
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
  end

  test "should get a template from the provision interface" do
    os = FactoryBot.create(:debian7_0, :with_provision, :with_associations)
    host = FactoryBot.create(:host, :managed, :build => true, :operatingsystem => os,
                              :organization => @org,
                              :location => @loc,
                              :interfaces => [
                                FactoryBot.build(:nic_managed, :primary => true),
                                FactoryBot.build(:nic_managed, :provision => true)
                              ])

    @request.env["REMOTE_ADDR"] = host.provision_interface.ip
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
  end

  test "should get a preseed finish script" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    get :host_template, params: { :kind => 'finish' }
    assert_response :success
  end

  test "should get a preseed finish script with multiple ips in the request header" do
    @request.env["REMOTE_ADDR"] = [@ub_host.ip, '1.2.3.4'].join(', ')
    get :host_template, params: { :kind => 'finish' }
    assert_response :success
  end

  test "should get a preseed" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
  end

  test "unattended files content type should be text/plain" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
    assert @response.headers["Content-Type"].match("text/plain")
  end

  test "should set @static when requested" do
    Setting[:safemode_render]=false
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
    get(:host_template, params: { 'kind' => 'provision', 'static' => 'true' })
    assert_match(%r{static:true}, @response.body)
  end

  test "should support spoof" do
    get :host_template, params: { :kind => 'provision', :spoof => @ub_host.ip }, session: set_session_user
    assert_response :success
  end

  test "should not render spoof when user is not logged in" do
    get :host_template, params: { :kind => 'provision', :spoof => @ub_host.ip }
    assert_response :redirect
  end

  test "should not render hostname spoof when user is not logged in" do
    get :host_template, params: { :kind => 'provision', :hostname => @ub_host.fqdn }
    assert_response :redirect
  end

  test "should not render hostname spoof when hostname is empty" do
    get :host_template, params: { :kind => 'provision', :hostname => nil }, session: set_session_user
    assert_response 404
  end

  test "should not render hostname spoof when spoof is empty" do
    get :host_template, params: { :kind => 'provision', :spoof => nil }, session: set_session_user
    assert_response 404
  end

  test "should support spoof using hostname" do
    get :host_template, params: { :kind => 'provision', :hostname => @ub_host.name }, session: set_session_user
    assert_response :success
    assert_equal @ub_host.name, assigns(:host).name
  end

  test "should provide pxe config for redhat" do
    get :host_template, params: { :kind => 'PXELinux', :spoof => @rh_host.ip }, session: set_session_user
    assert_response :success
  end

  test "should provide pxe config for debian" do
    get :host_template, params: { :kind => 'PXELinux', :spoof => @ub_host.ip }, session: set_session_user
    assert_response :success
  end

  test "should render spoof pxelinux for a host" do
    get :host_template, params: { :kind => 'PXELinux', :spoof => @rh_host.ip }, session: set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof pxegrub for a host" do
    get :host_template, params: { :kind => 'PXEGrub', :spoof => @rh_host.ip }, session: set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof iPXE for a host" do
    get :host_template, params: { :kind => 'iPXE', :spoof => @rh_host.ip }, session: set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof gpxe for a host" do
    get :host_template, params: { :kind => 'gPXE', :spoof => @rh_host.ip }, session: set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test 'should route built notifications' do
    assert_routing '/unattended/built', {:controller => 'unattended', :action => 'built', :format => 'text'}
  end

  test "should accept built notifications" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    get :built
    assert_response :created
    host = Nic::Base.primary.find_by_ip(@ub_host.ip)
    assert_equal host.build,false
  end

  test "should accept built notifications_with_expired_token" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    @ub_host.create_token(:value => "expired_token", :expires => Time.now.utc - 1.minute)
    get :built, params: {'token' => @ub_host.token.value }
    assert_response :created
    host = Nic::Base.primary.find_by_ip(@ub_host.ip)
    assert_equal host.build,false
  end

  test "should not render a template when token is expired" do
    Setting[:token_duration] = 30
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    @ub_host.create_token(:value => "expired_token", :expires => Time.now.utc - 1.minute)
    get :host_template, params: { :kind => 'provision'}
    assert_response :precondition_failed
  end

  test "should not find host by ip if token is present" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    get :host_template, params: { :kind => 'provision', :token => 'invalid' }
    assert_response :not_found
  end

  test "should not provide unattened files to hosts which are not in built state" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
    @request.env['REMOTE_ADDR'] = '10.0.1.2'
    get :built
    assert_response :created
    get :host_template, params: { :kind => 'provision' }
    assert_response :method_not_allowed
  end

  test "should provide unattened files to hosts which are not in built state when access_unattended_without_build=true" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
    @request.env['REMOTE_ADDR'] = '10.0.1.2'
    Setting[:access_unattended_without_build] = true
    get :built
    assert_response :created
    get :host_template, params: { :kind => 'provision' }
    assert_response :success
  end

  test "should not provide unattended files to hosts which we don't know about" do
    get :host_template, params: { :kind => 'provision' }
    assert_response :not_found
  end

  test "should not provide unattended files to hosts which don't have an assign os" do
    setup_users

    @rh_host.update_attribute(:operatingsystem_id, nil)
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
    get :host_template, params: { :kind => 'provision' }
    assert_response :conflict
  end

  test "template with nested hostgroup should be rendered" do
    get :hostgroup_template, params: { :id => "MyString", :hostgroup => "Parent/inherited" }
    assert_response :success
  end

  test "template with hostgroup should be rendered" do
    get :hostgroup_template, params: { :id => "MyString", :hostgroup => "Common" }
    assert_response :success
  end

  test "template with hostgroup should be identified as hostgroup provisioning" do
    ProvisioningTemplate.any_instance.stubs(:template).returns("type:<%= @provisioning_type %>")
    hostgroups(:common).update_attribute :ptable_id, FactoryBot.create(:ptable).id
    get :hostgroup_template, params: { :id => "MyString2", :hostgroup => "Common" }
    assert_response :success
    assert_match(%r{type:hostgroup}, @response.body)
  end

  test "template with host should be identified as host provisioning" do
    ProvisioningTemplate.any_instance.stubs(:template).returns("type:<%= @provisioning_type %>")
    get :host_template, params: { :kind => 'provision', :hostname => @ub_host.name }, session: set_session_user
    assert_response :success
    assert_match(%r{type:host\z}, @response.body)
  end

  test "template with hostgroup should be rendered even if both have periods in their names" do
    templates(:mystring).update_attributes(:name => 'My.String')
    hostgroups(:common).update_attributes(:name => 'Com.mon')
    assert_routing '/unattended/template/My.String/Com.mon', {:controller => 'unattended', :action => 'hostgroup_template', :id => "My.String", :hostgroup => "Com.mon", :format => 'text'}
    get :hostgroup_template, params: { :id => "My.String", :hostgroup => "Com.mon" }
    assert_response :success
  end

  test "template with non-existant  hostgroup should not be rendered" do
    get :hostgroup_template, params: { :id => "MyString2", :hostgroup => "NotArealHostgroup" }
    assert_response :not_found
  end

  test "requesting a template that does not exist should fail" do
    get :hostgroup_template, params: { :id => "kdsfjlkasjdfkl", :hostgroup => "Common" }
    assert_response :not_found
  end

  # All the following tests exercise the renderer, and should probably be reviewed
  # once the refactoring of foreman_url is complete
  test "template should contain tokens when tokens enabled and present for the host" do
    token = "mytoken"
    Setting[:token_duration] = 30
    Setting[:unattended_url]    = "https://test.host"
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    @ub_host.create_token(:value => token, :expires => Time.now.utc + 5.minutes)
    get :host_template, params: { :kind => 'provision', 'token' => @ub_host.token.value }
    assert @response.body.include?("#{Setting[:unattended_url]}/unattended/finish?token=#{token}")
  end

  test "hosts with unknown ip and valid token should render a template" do
    Setting[:token_duration] = 30
    @request.env["REMOTE_ADDR"] = '127.0.0.1'
    @ub_host.create_token(:value => "aaaaaa", :expires => Time.now.utc + 5.minutes)
    get :host_template, params: { :kind => 'provision', 'token' => @ub_host.token.value }
    assert_response :success
  end

  context "template with host parameters" do
    setup do
      @host_param = FactoryBot.create(:host_parameter, :host => @rh_host, :name => 'my_param')
      @secret_param = FactoryBot.create(:host_parameter, :host => @rh_host, :name => 'secret_param')
      @rh_host.provisioning_template(:kind => :provision).update_attribute(:template, "params: <%= host_param('my_param') %>, <%= host_param('secret_param') %>")
      setup_user 'view', 'hosts'
      setup_user 'view', 'params', 'name = my_param'
      users(:one).organizations << @rh_host.organization
      users(:one).locations << @rh_host.location
    end

    test "in preview should only show permitted parameters" do
      get :host_template, params: { :kind => 'provision', :hostname => @rh_host.name }, session: set_session_user(:one)
      assert_equal "params: #{@host_param.value}, ", @response.body
    end

    test "in unattended mode should show all parameters" do
      @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
      get :host_template, params: { :kind => 'provision' }
      assert_equal "params: #{@host_param.value}, #{@secret_param.value}", @response.body
    end

    context "and ptable with host parameters" do
      setup do
        as_admin do
          @rh_host.ptable.update_attribute(:template, "params: <%= host_param('my_param') %>, <%= host_param('secret_param') %>")
          @rh_host.provisioning_template(:kind => :provision).update_attribute(:template, "ptable: <%= @host.diskLayout %>\nparams: <%= host_param('my_param') %>, <%= host_param('secret_param') %>")
        end
      end

      test "in preview should only show permitted parameters" do
        get :host_template, params: { :kind => 'provision', :hostname => @rh_host.name }, session: set_session_user(:one)
        assert_equal "ptable: params: #{@host_param.value}, \nparams: #{@host_param.value}, ", @response.body
      end

      test "in unattended mode should show all parameters" do
        @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{@rh_host.mac}"
        get :host_template, params: { :kind => 'provision' }
        assert_equal "ptable: params: #{@host_param.value}, #{@secret_param.value}\nparams: #{@host_param.value}, #{@secret_param.value}", @response.body
      end
    end
  end

  context "location or organizations are not enabled" do
    before do
      SETTINGS[:locations_enabled] = false
      SETTINGS[:organizations_enabled] = false
    end

    after do
      SETTINGS[:locations_enabled] = true
      SETTINGS[:organizations_enabled] = true
    end

    test "hosts with mismatched ip and update_ip=false should have the old ip" do
      disable_orchestration # avoids dns errors
      Setting[:token_duration] = 30
      Setting[:update_ip_from_built_request] = false
      @request.env["REMOTE_ADDR"] = '127.0.0.1'
      h=@ub_host
      h.create_token(:value => "aaaaaa", :expires => Time.now.utc + 5.minutes)
      get :built, params: { 'token' => h.token.value }
      h_new=Host.find_by_name(h.name)

      assert_response :success
      assert_equal h.ip, h_new.ip
    end

    test "hosts with mismatched ip and update_ip true should have the new ip" do
      disable_orchestration # avoids dns errors
      Setting[:token_duration] = 30
      Setting[:update_ip_from_built_request] = true
      h=@ub_host
      new_ip = h.subnet.network.gsub(/\.0$/,'.100') # Must be in the subnet, which isn't fixed
      @request.env["REMOTE_ADDR"] = new_ip
      refute_equal new_ip, h.ip
      h.create_token(:value => "aaaaab", :expires => Time.now.utc + 5.minutes)
      get :built, params: { 'token' => h.token.value }
      h_new=Host.find_by_name(h.reload.name)
      assert_response :success
      assert_equal new_ip, h_new.ip
    end

    test "hosts with mismatched ip and update_ip true and a duplicate ip should succeed with no ip update" do
      disable_orchestration # avoids dns errors
      Setting[:token_duration] = 30
      Setting[:update_ip_from_built_request] = true
      @request.env["REMOTE_ADDR"] = @rh_host.ip
      h=@ub_host
      h.create_token(:value => "aaaaac", :expires => Time.now.utc + 5.minutes)
      get :built, params: { 'token' => h.token.value }
      assert_response :success
      h_new=Host.find_by_name(h.reload.name)
      assert_equal h.ip, h_new.ip
    end

    # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
    test "template should contain tokens when tokens enabled and present for the host" do
      Setting[:token_duration]    = 30
      Setting[:unattended_url]    = "http://test.host"
      @request.env["REMOTE_ADDR"] = @ub_host.ip
      @ub_host.create_token(:value => "aaaaaa", :expires => Time.now.utc + 5.minutes)
      get :host_template, params: { :kind => 'provision' }
      assert @response.body.include?("http://test.host/unattended/finish?token=aaaaaa")
    end
  end # end of context "location or organizations are not enabled"

  test "hosts with a template proxy which supplies a templateServer should use it" do
    template_server_from_proxy = 'https://someproxy:8443'
    ProxyAPI::Template.any_instance.stubs(:template_url).returns(template_server_from_proxy)
    @request.env["REMOTE_ADDR"] = '127.0.0.1'
    @host_with_template_subnet.create_token(:value => "aaaaad", :expires => Time.now.utc + 5.minutes)
    get :host_template, params: { :kind => 'provision', 'token' => @host_with_template_subnet.token.value }
    assert @response.body.include?("#{template_server_from_proxy}/unattended/finish?token=aaaaad")
  end

  test "hosts with a template proxy with no templateServer should use the proxy name" do
    Setting[:token_duration] = 30
    Setting[:unattended_url] = "http://test.host"
    ProxyAPI::Template.any_instance.stubs(:template_url).returns(nil)
    @request.env["REMOTE_ADDR"] = '127.0.0.1'
    @host_with_template_subnet.create_token(:value => "aaaaae", :expires => Time.now.utc + 5.minutes)
    get :host_template, params: { :kind => 'provision', 'token' => @host_with_template_subnet.token.value }
    assert_includes @response.body, "#{@host_with_template_subnet.subnet.tftp.url}/unattended/finish?token=aaaaae"
  end

  # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
  test "template should not contain https when ssl enabled" do
    @request.env["HTTPS"] = "on"
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    get :host_template, params: { :kind => 'provision' }
    assert_match(%r{http://}, @response.body)
    assert_no_match(%r{https://}, @response.body)
  end

  test "should return and log error when template not found" do
    @request.env["REMOTE_ADDR"] = @ub_host.ip
    Host::Managed.any_instance.expects(:provisioning_template).returns(nil)
    get :host_template, params: { :kind => 'provision' }
    assert_response :not_found
  end

  test 'host template provision URL can be generated from routes' do
    assert_routing '/unattended/provision', {:controller => 'unattended', :action => 'host_template', :kind => 'provision', :format => 'text'}
  end

  test "should not render a template to anonymous user" do
    get :host_template, params: { :kind => 'PXELinux', :spoof => @rh_host.ip, :format => 'text' }
    assert_response :redirect
  end

  test "should not render a template to user w/o email" do
    user = FactoryBot.create(:user)
    get :host_template, params: { :kind => 'PXELinux', :spoof => @rh_host.ip, :format => 'text' }, session: set_session_user(user)
    assert_response :unprocessable_entity
  end

  test 'should render a template to user with valid filter' do
    user = FactoryBot.build(:user, :with_mail, :admin => false,
                              :organizations => [@org], :locations => [@loc])
    user_role = roles(:destroy_hosts)
    user.roles << user_role
    user.save
    FactoryBot.create(:filter, :role => user_role,
                       :permissions => Permission.where(:name => 'view_hosts'),
                       :search => "name = #{@rh_host.name}")
    get :host_template, params: { :kind => 'PXELinux', :spoof => @rh_host.ip, :format => 'text' }, session: set_session_user(user)
    assert_response :success
    assert @response.body.include?("linux")
  end

  test 'should not render a template to user with invalid filter' do
    user = FactoryBot.create(:user, :with_mail, :admin => false)
    user_role = roles(:destroy_hosts)
    user.roles << user_role
    user.save

    FactoryBot.create(:filter, :role => user_role,
                       :permissions => Permission.where(:name => 'view_hosts'),
                       :search => "name = does_not_exist")
    get :host_template, params: { :kind => 'PXELinux', :spoof => @rh_host.ip, :format => 'text' }, session: set_session_user(user)
    assert_response :not_found
    assert_match /unable to find a host/, @response.body
  end
end
