class CalendarController < ApplicationController
  before_action :set_rooms, only: [:index, :reservations]

  def index
  end

  def help
  end

  def reservations
    start_time = Time.parse(params[:start])
    end_time = Time.parse(params[:end])
    reservations = no_repeat_reservations(start_time, end_time) +
      weekly_reservations(start_time, end_time)
    render json: reservations
  end

  private
  
  def set_rooms
    @rooms = Room.includes(:office).order("office_id, id")
    rgb = [0, 24, 64]
    base = 0xff - rgb.max
    e = rgb.permutation.cycle
    @room_colors = @rooms.each_with_object({}) { |room, h|
      h[room.id] = "#" + e.next.map { |i|
        "%02x" % (base + i)
      }.join
    }
  end

  def reservation_event(reservation,
                        start_at = reservation.start_at,
                        end_at = reservation.end_at)
    {
      title: "#{reservation.purpose}（#{reservation.representative}）",
      start: start_at,
      end: end_at,
      color: @room_colors[reservation.room_id],
      url: url_for(reservation)
    }
  end

  def no_repeat_reservations(start_time, end_time)
    reservations = Reservation.no_repeat.where(
      "start_at < ? AND end_at > ?",
      end_time, start_time
    ).order("start_at, id").map { |reservation|
      reservation_event(reservation)
    }
  end

  def weekly_reservations(start_time, end_time)
    Reservation.weekly.where("repeating_mode = 1").
      order("start_at, id").flat_map { |reservation|
      offset = reservation.start_at.wday - start_time.wday
      if offset < 0
        offset += 7
      end
      a = []
      t = start_time + offset.days +
        (reservation.start_at - reservation.start_at.beginning_of_day)
      while t < end_time
        a << reservation_event(reservation, t,
                               reservation.end_at +
                               (t - reservation.start_at))
        t += 7.days
      end
      a
    }
  end
end
