require 'test_helper'

class ReservationCancelsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @reservationcancel = reservations(:mendan)
  end 


  test "should reservation cancels" do
    post "/reservations/#{@reservationcancel.id}/reservation_cancels" ,params:{reservation_cancel: {id: @reservationcancel.id,start_on:@reservationcancel.start_at}}
    assert_response :redirect
  end
end
