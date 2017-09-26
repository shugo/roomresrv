require "net/http"

class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:edit, :update, :destroy]
  before_action :set_rooms, only: [:new, :edit]
  after_action :remember_fields, only: [:create, :update]
  after_action :invoke_slack_webhook, only: [:create, :update]

  # GET /reservations
  # GET /reservations.json
  def index
    @reservations = Reservation.all
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
    @reservation = Reservation.includes(:room => :office).find(params[:id])
    if @reservation.weekly? && params[:date]
      date = Date.parse(params[:date])
      @reservation_cancel = ReservationCancel.new(reservation: @reservation,
                                                  start_on: date)
      offset = date - @reservation.start_at.to_date
      @start_at = @reservation.start_at.since(offset.days)
      @end_at = @reservation.end_at.since(offset.days)
    else
      @start_at = @reservation.start_at
      @end_at = @reservation.end_at
    end
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
    if session[:representative]
      @reservation.representative = session[:representative]
    end
    if cookies[:roomresrv_room_id]
      @reservation.room_id = cookies[:roomresrv_room_id]
    end
    if params[:date]
      @reservation.start_at = Time.parse(params[:date])
    else
      @reservation.start_at = Time.at((Time.now.to_i / 3600.0).ceil * 3600)
    end
    @reservation.end_at = Time.at(@reservation.start_at.to_i + 3600)
  end

  # GET /reservations/1/edit
  def edit
    if @reservation.weekly? && params[:date]
      t = Time.parse(params[:date])
      @reservation.start_at = Time.zone.local(t.year, t.month, t.day,
                                              @reservation.start_at.hour,
                                              @reservation.start_at.min,
                                              @reservation.start_at.sec)
      @reservation.end_at = Time.zone.local(t.year, t.month, t.day,
                                            @reservation.end_at.hour,
                                            @reservation.end_at.min,
                                            @reservation.end_at.sec)
    end
  end

  # POST /reservations
  # POST /reservations.json
  def create
    Reservation.transaction do
      @reservation = Reservation.new(reservation_params)
      @reservation.room.lock!

      respond_to do |format|
        if @reservation.save
          @invoke_slack_webhook = true
          format.html { redirect_to @reservation, notice: '予約を登録しました' }
          format.json { render :show, status: :created, location: @reservation }
          if @reservation.room_id == 0 && !ENV["SCHEDULE_EMAIL_ADDRESS"].blank?
            ScheduleMailer.schedule_mail(@reservation).deliver_now
          end
        else
          @invoke_slack_webhook = false
          format.html do
            set_rooms
            render :new
          end
          format.json { render json: @reservation.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    Reservation.transaction do
      respond_to do |format|
        @reservation.attributes = reservation_params
        @reservation.room.lock!
        room_or_time_changed =
          @reservation.room_id_changed? || @reservation.start_at_changed?

        if @reservation.weekly? && (request.xhr? || params[:only_day])
          reservation_cancel =
            ReservationCancel.create!(reservation: @reservation,
                                      start_on: params[:date])
          @reservation = @reservation.dup
          @reservation.repeating_mode = "no_repeat"
        end

        if @reservation.save
          @invoke_slack_webhook = room_or_time_changed
          format.html {
            # Use reservation_url to avoid a brakeman warning.
            redirect_to reservation_url(@reservation),
            notice: '予約を更新しました'
          }
          format.json { render :show, status: :ok, location: @reservation }
        else
          reservation_cancel.destroy if reservation_cancel
          @invoke_slack_webhook = false
          format.html do
            set_rooms
            render :edit
          end
          format.json { render json: @reservation.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation.destroy
    respond_to do |format|
      format.html { redirect_to "/calendar/index", notice: '予約を削除しました' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def set_rooms
      @rooms = Room.includes(:office).ordered
    end

    WDAYS = ["日", "月", "火", "水", "木", "金", "土"]

    def remember_fields
      if @reservation.persisted? && !@reservation.changed?
        session[:representative] = @reservation.representative
        cookies[:roomresrv_room_id] = @reservation.room_id
      end
    end

    def invoke_slack_webhook
      return if ENV["SLACK_WEBHOOK_URL"].blank? || !@invoke_slack_webhook

      wday = WDAYS[@reservation.start_at.wday]
      time = @reservation.start_at.strftime("%Y/%m/%d(#{wday}) %H:%M")
      room = @reservation.room.name_with_office
      title = "#{@reservation.purpose}（#{@reservation.representative}）"
      url = reservation_url(@reservation)
      form = {
        "payload" => {
          "text" => "#{time}に#{room}が予約されました: 「#{title}」 #{url}"
        }.to_json
      }
      res = Net::HTTP.post_form(URI.parse(ENV["SLACK_WEBHOOK_URL"]), form)
      if res.code != "200"
        logger.error("Slack Webhook failed: #{res.code} #{res.message}: #{res.body}")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:room_id, :representative, :purpose, :num_participants, :start_at, :end_at, :repeating_mode, :lock_version,:note)
    end
end
