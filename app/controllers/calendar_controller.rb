class CalendarController < ApplicationController
  COLORS = ["#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854", "#ffd92f", "#e5c494", "#b3b3b3"]

  def index
    @room_colors = get_room_colors
  end

  def reservations
    start_time = Time.parse(params[:start])
    end_time = Time.parse(params[:end])
    room_colors = get_room_colors
    reservations =
      non_repeating_reservations(room_colors, start_time, end_time) +
      weekly_reservations(room_colors, start_time, end_time) +
      monthly_reservations(room_colors, start_time, end_time)
    render json: reservations
  end

  private
  
  def get_room_colors
    e = COLORS.cycle
    Room.order("id").each_with_object({}) { |room, h|
      h[room.id] = e.next
    }
  end

  def reservation_event(room_colors, reservation,
                        start_at = reservation.start_at,
                        end_at = reservation.end_at)
    {
      title: "#{reservation.purpose}（#{reservation.representative}）",
      start: start_at,
      end: end_at,
      color: room_colors[reservation.room.id],
      url: url_for(reservation)
    }
  end

  def non_repeating_reservations(room_colors, start_time, end_time)
    reservations = Reservation.includes(:room).where(
      "repeating_mode = 0 AND start_at < ? AND end_at > ?",
      end_time, start_time
    ).order("start_at, id").map { |reservation|
      reservation_event(room_colors, reservation)
    }
  end

  def weekly_reservations(room_colors, start_time, end_time)
    Reservation.includes(:room).where("repeating_mode = 1").
      order("start_at, id").flat_map { |reservation|
      offset = reservation.start_at.wday - start_time.wday
      if offset < 0
        offset += 7
      end
      a = []
      t = start_time + offset.days +
        (reservation.start_at - reservation.start_at.beginning_of_day)
      while t < end_time
        a << reservation_event(room_colors, reservation, t,
                               reservation.end_at +
                               (t - reservation.start_at))
        t += 7.days
      end
      a
    }
  end

  def monthly_reservations(room_colors, start_time, end_time)
    Reservation.includes(:room).where("repeating_mode = 2").
      order("start_at, id").flat_map { |reservation|
      day = reservation.start_at.day
      a = []
      t = Time.mktime(start_time.year, start_time.month, day) +
        (reservation.start_at - reservation.start_at.beginning_of_day)
      while t < end_time
        a << reservation_event(room_colors, reservation, t,
                               reservation.end_at +
                               (t - reservation.start_at))
        t = t.months_since(1)
      end
      a
    }
  end
end
