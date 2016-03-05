require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  setup do
    @reservation = Reservation.new(room: rooms(:ousetsu),
                                   representative: "前田",
                                   purpose: "A社加藤様来社",
                                   num_participants: 3,
                                   start_at: Time.mktime(2016, 3, 7, 15, 0, 0),
                                   end_at: Time.mktime(2016, 3, 7, 16, 0, 0))
    @reservation.save!
  end

  test "before another reservation" do
    r = Reservation.new(room: @reservation.room,
                        representative: "鈴木",
                        purpose: "B社佐藤様来社",
                        num_participants: 3,
                        start_at: @reservation.start_at - 2.hour,
                        end_at: @reservation.start_at - 1.hour)
    assert_equal(true, r.save)
  end

  test "after another reservation" do
    r = Reservation.new(room: @reservation.room,
                        representative: "鈴木",
                        purpose: "B社佐藤様来社",
                        num_participants: 3,
                        start_at: @reservation.end_at + 1.hour,
                        end_at: @reservation.end_at + 2.hour)
    assert_equal(true, r.save)
  end

  test "just before another reservation" do
    r = Reservation.new(room: @reservation.room,
                        representative: "鈴木",
                        purpose: "B社佐藤様来社",
                        num_participants: 3,
                        start_at: @reservation.start_at - 1.hour,
                        end_at: @reservation.start_at)
    assert_equal(true, r.save)
  end

  test "just after another reservation" do
    r = Reservation.new(room: @reservation.room,
                        representative: "鈴木",
                        purpose: "B社佐藤様来社",
                        num_participants: 3,
                        start_at: @reservation.end_at,
                        end_at: @reservation.end_at + 1.hour)
    assert_equal(true, r.save)
  end

  test "same schedule as another reservation" do
    r = Reservation.new(room: @reservation.room,
                        representative: "鈴木",
                        purpose: "B社佐藤様来社",
                        num_participants: 3,
                        start_at: @reservation.start_at,
                        end_at: @reservation.end_at)
    assert_equal(false, r.save)
  end

  test "same schedule as another reservation but their rooms are different" do
    r = Reservation.new(room: rooms(:kitchen),
                        representative: "鈴木",
                        purpose: "B社佐藤様来社",
                        num_participants: 3,
                        start_at: @reservation.start_at,
                        end_at: @reservation.end_at)
    assert_equal(true, r.save)
  end

  test "other schedule conflicts" do
    [
      [@reservation.start_at - 30.minutes, @reservation.start_at + 30.minutes],
      [@reservation.end_at - 30.minutes, @reservation.end_at + 30.minutes],
      [@reservation.start_at - 10.minutes, @reservation.end_at + 10.minutes],
      [@reservation.start_at + 10.minutes, @reservation.end_at - 10.minutes],
    ].each do |start_at, end_at|
      r = Reservation.new(room: @reservation.room,
                          representative: "鈴木",
                          purpose: "B社佐藤様来社",
                          num_participants: 3,
                          start_at: start_at,
                          end_at: end_at)
      assert_equal(false, r.save)
    end
  end
end
