require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get reservations when start and end is given" do
    Reservation.create!([
      {
        room: rooms(:ousetsu),
        representative: "foo",
        purpose: "bar",
        num_participants: 3,
        start_at: Time.mktime(2015, 10, 31, 23, 0, 0),
        end_at: Time.mktime(2015, 11, 1, 0, 0, 0)
      },
      {
        room: rooms(:ousetsu),
        representative: "foo",
        purpose: "bar",
        num_participants: 3,
        start_at: Time.mktime(2016, 3, 1, 0, 0, 0),
        end_at: Time.mktime(2016, 3, 1, 1, 0, 0)
      }
    ])

    reservations = Reservation.create!([
      {
        room: rooms(:ousetsu),
        representative: "representative1",
        purpose: "purpose1",
        num_participants: 3,
        start_at: Time.mktime(2015, 11, 1, 0, 0, 0),
        end_at: Time.mktime(2015, 11, 1, 1, 0, 0)
      },
      {
        room: rooms(:ousetsu),
        representative: "representative1",
        purpose: "purpose2",
        num_participants: 3,
        start_at: Time.mktime(2015, 12, 1, 13, 0, 0),
        end_at: Time.mktime(2015, 12, 1, 14, 0, 0)
      },
      {
        room: rooms(:ousetsu),
        representative: "representative1",
        purpose: "purpose3",
        num_participants: 4,
        start_at: Time.mktime(2016, 2, 29, 23, 0, 0),
        end_at: Time.mktime(2016, 3, 1, 0, 0, 0)
      },
      {
        room: rooms(:kitchen),
        representative: "representative2",
        purpose: "purpose4",
        num_participants: 5,
        start_at: Time.mktime(2015, 10, 31, 23, 0, 0),
        end_at: Time.mktime(2015, 11, 1, 1, 0, 0)
      },
      {
        room: rooms(:kitchen),
        representative: "representative1",
        purpose: "purpose5",
        num_participants: 3,
        start_at: Time.mktime(2015, 12, 1, 13, 0, 0),
        end_at: Time.mktime(2015, 12, 1, 14, 0, 0)
      },
      {
        room: rooms(:kitchen),
        representative: "representative2",
        purpose: "purpose6",
        num_participants: 2,
        start_at: Time.mktime(2016, 2, 29, 23, 0, 0),
        end_at: Time.mktime(2016, 3, 1, 1, 0, 0)
      },
      {
        room: rooms(:meeting_room),
        representative: "representative3",
        purpose: "purpose7",
        num_participants: 10,
        start_at: Time.mktime(2015, 10, 31, 23, 0, 0),
        end_at: Time.mktime(2016, 3, 1, 1, 0, 0)
      }
    ]).sort_by { |r| [r.start_at, r.id] }

    wr = Reservation.create!({
      room: rooms(:ousetsu),
      representative: "representative1",
      purpose: "purpose8",
      num_participants: 4,
      start_at: Time.mktime(2015, 1, 1, 13, 0, 0),
      end_at: Time.mktime(2015, 1, 1, 14, 0, 0),
      repeating_mode: :weekly
    })

    get :reservations,
      start: Time.mktime(2015, 11, 1, 0, 0, 0),
      end: Time.mktime(2016, 3, 1, 0, 0, 0)

    assert_response :success
    assert_equal(reservations.length + 17, json.length)

    json.take(reservations.length).zip(reservations) do |j, r|
      assert_equal(r.room.name, j["room"])
      assert_equal(r.room.office.name, j["office"])
      assert_equal("#{r.purpose}（#{r.representative}）", j["title"])
      assert_equal(json_time(r.start_at), j["start"])
      assert_equal(json_time(r.end_at), j["end"])
      assert_equal(reservation_url(r), j["url"])
    end

    ts = []
    t = Time.mktime(2015, 11, 5, 13, 0, 0)
    et = Time.mktime(2016, 3, 1, 0, 0, 0)
    while t < et
      ts.push(t)
      t += 7.days
    end
    json.drop(reservations.length).zip(ts).each do |j, t|
      assert_equal(wr.room.name, j["room"])
      assert_equal(wr.room.office.name, j["office"])
      assert_equal("#{wr.purpose}（#{wr.representative}）", j["title"])
      assert_equal(json_time(t), j["start"])
      assert_equal(json_time(t + 1.hour), j["end"])
      assert_equal(reservation_url(wr), j["url"])
    end
  end

  test "should get today's reservations when neither start nor end is given" do
    beginning_of_today = Time.now.beginning_of_day
    Reservation.create!([
      {
        room: rooms(:ousetsu),
        representative: "foo",
        purpose: "bar",
        num_participants: 3,
        start_at: beginning_of_today - 1.hour,
        end_at: beginning_of_today
      },
      {
        room: rooms(:ousetsu),
        representative: "foo",
        purpose: "bar",
        num_participants: 3,
        start_at: beginning_of_today + 1.day,
        end_at: beginning_of_today + (1.day + 1.hour)
      }
    ])
    reservations = Reservation.create!([
      {
        room: rooms(:ousetsu),
        representative: "foo",
        purpose: "bar",
        num_participants: 3,
        start_at: beginning_of_today,
        end_at: beginning_of_today + 1.hour
      },
      {
        room: rooms(:ousetsu),
        representative: "foo",
        purpose: "bar",
        num_participants: 3,
        start_at: beginning_of_today + 23.hour,
        end_at: beginning_of_today + 1.day
      }
    ])

    get :reservations

    assert_response :success
    assert_equal(reservations.length, json.length)

    json.zip(reservations) do |j, r|
      assert_equal(r.room.name, j["room"])
      assert_equal(r.room.office.name, j["office"])
      assert_equal("#{r.purpose}（#{r.representative}）", j["title"])
      assert_equal(json_time(r.start_at), j["start"])
      assert_equal(json_time(r.end_at), j["end"])
      assert_equal(reservation_url(r), j["url"])
    end
  end

  private

  def json_time(t)
    t.to_json.delete('"')
  end
end
