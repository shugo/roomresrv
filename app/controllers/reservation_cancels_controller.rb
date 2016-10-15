class ReservationCancelsController < ApplicationController
  def create
    ReservationCancel.create!(reservation_cancel_params)
    redirect_to "/calendar/index", notice: '繰り返し予約を一部削除しました'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def reservation_cancel_params
    params.require(:reservation_cancel).permit(:reservation_id, :start_on)
  end
end
