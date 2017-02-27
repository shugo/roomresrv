require 'test_helper'

class ReservationCancelsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @reservation = reservations(:mendan)
    @reservation.weekly!
  end 


  test "should reservation cancels" do
    date = (@reservation.start_at + 7.day).to_date
    post reservation_reservation_cancels_path(@reservation) ,params:{reservation_cancel:  {reservation_id: @reservation.id, start_on:date}}
    assert_redirected_to(controller:"calendar",action:"index")
    assert_equal(date,@reservation.reservation_cancels.first.start_on)
  end

end
