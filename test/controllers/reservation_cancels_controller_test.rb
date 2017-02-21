require 'test_helper'

class ReservationCancelsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @reservation = reservations(:kaigi)
    @reservation.start_at += 7.day
  end 


  test "should reservation cancels" do
    post reservation_reservation_cancels_path(@reservation) ,params:{reservation_cancel:  {start_on: @reservation.start_at}}
    assert_redirected_to(controller:"calendar",action:"index")
    r = ReservationCancel.find_by(start_on: @reservation.start_at)
    assert_equal(false,r.nil?)
  end

end
