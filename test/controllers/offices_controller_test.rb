require 'test_helper'

class OfficesControllerTest < ActionController::TestCase
  setup do
    @office = offices(:matsue)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create office" do
    assert_difference('Office.count') do
      post :create, params: { office: { name: @office.name + "2" } }
    end

    assert_redirected_to office_path(assigns(:office))
  end

  test "should show office" do
    get :show, params: { id: @office }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @office }
    assert_response :success
  end

  test "should update office" do
    patch :update, params: { id: @office, office: { name: @office.name } }
    assert_redirected_to office_path(assigns(:office))
  end

  test "should destroy office" do
    @office.rooms.each do |room|
      room.reservations.destroy_all
    end
    @office.rooms.destroy_all
    assert_difference('Office.count', -1) do
      delete :destroy, params: { id: @office }
    end

    assert_redirected_to offices_path
  end
end
