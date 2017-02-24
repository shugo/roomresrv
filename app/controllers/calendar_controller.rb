class CalendarController < ApplicationController
  before_action :set_rooms, only: [:index, :reservations]

  AVAILABLE_VIEWS = ["month", "agendaWeek", "agendaDay"]

  def index
    if params[:view]
      if AVAILABLE_VIEWS.include?(params[:view])
        cookies[:roomresrv_default_view] = params[:view]
      else
        flash[:notice] = "viewパラメータの値が不正です: #{params[:view]}"
      end
    end
    if params[:date]
      case params[:date]
      when /\A\d{4}-\d{2}-\d{2}\z/
        cookies[:roomresrv_default_date] = params[:date]
      when "today"
        cookies[:roomresrv_default_date] = Date.today.iso8601
      else
        flash[:notice] = "dateパラメータの値が不正です: #{params[:date]}"
      end
    end
    if request.from_smartphone?
      @room_id = cookies[:roomresrv_room_id] || @rooms[0].id
    else
      if cookies[:roomresrv_selected_rooms]
        @selected_rooms =
          cookies[:roomresrv_selected_rooms].split(",").map(&:to_i)
      else
        @selected_rooms = @rooms.map(&:id)
      end
    end
  end

  def help
  end

  def reservations
    start_time = params[:start] ?
      Time.parse(params[:start]) : Time.now.beginning_of_day
    end_time = params[:end] ?
      Time.parse(params[:end]) : start_time.end_of_day
    reservations = no_repeat_reservations(start_time, end_time) +
      weekly_reservations(start_time, end_time)
    render json: reservations
  end

  private

  ROOM_COLORS = [
    "#9acced",
    "#97e6b8",
    "#cdacdb",
    "#f3bf91",
    "#f3a69e",
    "#8ddece"
  ]

  def set_rooms
    @rooms = Room.includes(:office).ordered
    e = ROOM_COLORS.cycle
    @room_colors = @rooms.each_with_object({}) { |room, h|
      h[room.id] = e.next
    }
  end

  def reservation_event(reservation,
                        start_at = reservation.start_at,
                        end_at = reservation.end_at)
    {
      id: reservation.id.to_s + start_at.strftime("-%Y-%m-%d"),
      title: "#{reservation.purpose}（#{reservation.representative}）",
      representative: reservation.representative,
      purpose: reservation.purpose,
      room: reservation.room.name,
      roomId: reservation.room.id,
      office: reservation.room.office.name,
      start: start_at,
      end: end_at,
      repeatingMode: reservation.repeating_mode,
      color: @room_colors[reservation.room_id],
      textColor: "#444444",
      url: reservation_path(reservation, date: start_at.strftime("%Y-%m-%d"))
    }
  end

  def no_repeat_reservations(start_time, end_time)
    reservations = Reservation.includes(:room).no_repeat.where(
      "start_at < ? AND end_at > ?",
      end_time, start_time
    ).order("start_at, id").map { |reservation|
      reservation_event(reservation)
    }
  end

  def weekly_reservations(start_time, end_time)
    Reservation.includes(:room, :reservation_cancels).weekly.
      order("start_at, id").flat_map { |reservation|
      reservation.repeat_weekly(start_time, end_time).map { |r|
        reservation_event(reservation, r[:start_at], r[:end_at])
      }
    }
  end
end
