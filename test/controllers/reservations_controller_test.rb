require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  setup do
    @reservation = reservations(:mendan)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reservations)
  end

  test "should get new" do
    get :new
    assert_response :success

    r = assigns(:reservation)
    assert_equal(nil, r.representative)
    assert_equal(nil, r.room_id)
  end

  test "should get new with session data" do
    session[:representative] = "John Smith"
    session[:room_id] = rooms(:kitchen).id

    get :new
    assert_response :success

    r = assigns(:reservation)
    assert_equal("John Smith", r.representative)
    assert_equal(rooms(:kitchen).id, r.room_id)
  end

  test "should create reservation" do
    assert_difference('Reservation.count') do
      post :create, params: { reservation: { end_at: Time.now + 1.hour, num_participants: @reservation.num_participants, purpose: @reservation.purpose, representative: @reservation.representative, room_id: @reservation.room_id, start_at: Time.now } }
    end

    assert_redirected_to reservation_path(assigns(:reservation))
    assert_equal(true, assigns(:invoke_slack_webhook))
    assert_equal(@reservation.representative, session[:representative])
    assert_equal(@reservation.room_id, session[:room_id])
  end

  test "should show reservation" do
    get :show, params: { id: @reservation }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @reservation }
    assert_response :success
  end

  test "should update reservation without webhook" do
    patch :update, params: { id: @reservation, reservation: { end_at: @reservation.end_at, num_participants: @reservation.num_participants, purpose: @reservation.purpose, representative: @reservation.representative, room_id: @reservation.room_id, start_at: @reservation.start_at } }
    assert_redirected_to reservation_path(assigns(:reservation))
    assert_equal(false, assigns(:invoke_slack_webhook))
  end

  test "should update reservation with webhook when the room is changed" do
    patch :update, params: { id: @reservation, reservation: { end_at: @reservation.end_at, num_participants: @reservation.num_participants, purpose: @reservation.purpose, representative: @reservation.representative, room_id: rooms(:kitchen), start_at: @reservation.start_at } }
    assert_redirected_to reservation_path(assigns(:reservation))
    assert_equal(true, assigns(:invoke_slack_webhook))
    assert_equal(@reservation.representative, session[:representative])
    assert_equal(rooms(:kitchen).id, session[:room_id])
  end

  test "should update reservation with webhook when the start_at is changed" do
    patch :update, params: { id: @reservation, reservation: { end_at: @reservation.end_at, num_participants: @reservation.num_participants, purpose: @reservation.purpose, representative: @reservation.representative, room_id: @reservation.room_id, start_at: @reservation.start_at + 1.hour } }
    assert_redirected_to reservation_path(assigns(:reservation))
    assert_equal(true, assigns(:invoke_slack_webhook))
  end

  test "should destroy reservation" do
    assert_difference('Reservation.count', -1) do
      delete :destroy, params: { id: @reservation }
    end

    assert_redirected_to calendar_index_path
  end
end
