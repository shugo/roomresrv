class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  after_action :invoke_slack_webhook, only: [:create, :update]

  # GET /reservations
  # GET /reservations.json
  def index
    @reservations = Reservation.all
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
    if params[:date]
      @reservation.start_at = Time.parse(params[:date])
    else
      @reservation.start_at = Time.at((Time.now.to_i / 3600.0).ceil * 3600)
    end
    @reservation.end_at = Time.at(@reservation.start_at.to_i + 3600)
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(reservation_params)

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: '予約を登録しました' }
        format.json { render :show, status: :created, location: @reservation }
      else
        format.html { render :new }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
        format.html { redirect_to @reservation, notice: '予約を更新しました' }
        format.json { render :show, status: :ok, location: @reservation }
      else
        format.html { render :edit }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
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

    def invoke_slack_webhook
      return if ENV["SLACK_WEBHOOK_URL"].blank?

      uri = URI.parse(ENV["SLACK_WEBHOOK_URL"])
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == "https") do |http|
        req = Net::HTTP::Post.new(uri.path)
        time = @reservation.start_at.strftime("%Y/%m/%d(%a) %H:%M")
        room = @reservation.room.name_with_office
        url = reservation_url(@reservation)
        req.set_form_data("payload" => {
          "text" => "#{time}に#{room}が予約されました: #{url}"
        }.to_json)
        res = http.request(req)
        if res.code != "200"
          logger.error("Slack Webhook failed: #{res.code} #{res.message}: #{res.body}")
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:room_id, :representative, :purpose, :num_participants, :start_at, :end_at, :repeating_mode, :lock_version)
    end
end
