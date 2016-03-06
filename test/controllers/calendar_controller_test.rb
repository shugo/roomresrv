require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get reservations" do
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
      },
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

    get :reservations,
      start: Time.mktime(2015, 11, 1, 0, 0, 0),
      end: Time.mktime(2016, 3, 1, 0, 0, 0)
    assert_response :success
    assert_equal(reservations.length, json.length)
    reservations.zip(json) do |r, j|
      assert_equal("#{r.purpose}（#{r.representative}）", j["title"])
    end
  end
end
