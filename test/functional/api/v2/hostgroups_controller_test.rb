require 'test_helper'

class Api::V2::HostgroupsControllerTest < ActionController::TestCase
  def os_attrs
    {
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id
    }
  end

  valid_attrs = { :name => 'TestHostgroup' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hostgroups)
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups.empty?
  end

  test "should show individual record" do
    get :show, { :id => hostgroups(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  def last_hostgroup
    Hostgroup.unscoped.order(:id).last
  end

  test "should create hostgroup" do
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs }
    end
    assert_response :created
  end

  test "should create hostgroup with default pxe loader" do
    Operatingsystem.any_instance.expects(:preferred_loader).returns("PXELinux BIOS")
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs.merge(os_attrs) }
    end
    assert_equal "PXELinux BIOS", last_hostgroup.pxe_loader
    refute_nil last_hostgroup.operatingsystem
    assert_response :created
  end

  test "should create hostgroup with some pxe loader" do
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs.merge(:pxe_loader => "Grub2 UEFI SecureBoot") }
    end
    assert_equal "Grub2 UEFI SecureBoot", last_hostgroup.pxe_loader
    assert_response :created
  end

  test "should create hostgroup with non-PXE pxe loader" do
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs.merge(:pxe_loader => "") }
    end
    assert_equal "", last_hostgroup.pxe_loader
    assert_response :created
  end

  test "should update hostgroup" do
    put :update, { :id => hostgroups(:common).to_param, :hostgroup => valid_attrs }
    assert_response :success
  end

  test "should destroy hostgroups" do
    assert_difference('Hostgroup.count', -1) do
      delete :destroy, { :id => hostgroups(:unusual).to_param }
    end
    assert_response :success
  end

  test "should clone hostgroup" do
    assert_difference('Hostgroup.count') do
      post :clone, { :id => hostgroups(:common).to_param, :name => Time.now.utc.to_s }
    end
    assert_response :success
  end

  test "blocks API deletion of hosts with children" do
    assert hostgroups(:parent).has_children?
    assert_no_difference('Hostgroup.count') do
      delete :destroy, { :id => hostgroups(:parent).to_param }
    end
    assert_response :conflict
  end

  test "should create nested hostgroup with a parent" do
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs.merge(:parent_id => hostgroups(:common).id) }
    end
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, last_hostgroup.ancestry
  end

  test "should update a hostgroup to nested by passing parent_id" do
    put :update, { :id => hostgroups(:db).to_param, :hostgroup => {:parent_id => hostgroups(:common).id} }
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, Hostgroup.find_by_name("db").ancestry
  end

  test "user without view_params permission can't see hostgroup parameters" do
    setup_user "view", "hostgroups"
    hostgroup_with_parameter = FactoryGirl.create(:hostgroup, :with_parameter)
    get :show, {:id => hostgroup_with_parameter.to_param, :format => 'json'}
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see hostgroup parameters" do
    setup_user "view", "hostgroups"
    setup_user "view", "params"
    hostgroup_with_parameter = FactoryGirl.create(:hostgroup, :with_parameter)
    get :show, {:id => hostgroup_with_parameter.to_param, :format => 'json'}
    assert_not_empty JSON.parse(response.body)['parameters']
  end
end
