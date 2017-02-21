require 'test_helper'

class ReservationCancelsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @reservation = reservations(:kaigi)
  end 


  test "should reservation cancels" do
    post reservation_reservation_cancels_path(@reservation) ,params:{reservation_cancel:  {start_on: @reservation.start_at + 7.day}}
    assert_redirected_to(controller:"calendar",action:"index")
  end
end
