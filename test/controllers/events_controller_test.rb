require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup { @event = events(:one) }

  # --- authentication ---
  test "redirects to login when not authenticated" do
    get events_url
    assert_redirected_to login_path
    get event_url(@event)
    assert_redirected_to login_path
  end

  # --- index: every logged-in role can see the list ---
  test "any logged-in user (even guest) can see the event list" do
    sign_in_as(users(:guest))
    get events_url
    assert_response :success
  end

  # --- guest: list only, no detail/join/create ---
  test "guest cannot view event detail" do
    sign_in_as(users(:guest))
    get event_url(@event)
    assert_redirected_to events_path
  end

  test "guest cannot open the create form" do
    sign_in_as(users(:guest))
    get events_new_url
    assert_redirected_to events_path
  end

  test "guest cannot join" do
    sign_in_as(users(:guest))
    assert_no_difference "EventParticipation.count" do
      post join_event_url(@event)
    end
    assert_redirected_to events_path
  end

  # --- athlete: view + join, no create ---
  test "athlete can view detail and join, but cannot create" do
    sign_in_as(users(:one))
    get event_url(@event)
    assert_response :success

    assert_difference "EventParticipation.count", 1 do
      post join_event_url(@event)
    end
    assert_redirected_to event_path(@event)

    get events_new_url
    assert_redirected_to events_path
  end

  test "join is idempotent and leave removes it; me lists joined" do
    sign_in_as(users(:one))
    post join_event_url(@event)
    assert_no_difference "EventParticipation.count" do
      post join_event_url(@event) # joining again does nothing
    end

    get events_me_url
    assert_response :success
    assert_select "h2", text: @event.name

    assert_difference "EventParticipation.count", -1 do
      delete leave_event_url(@event)
    end
  end

  # --- coach: can create (records creator) ---
  test "coach can create an event and becomes its creator" do
    sign_in_as(users(:two))
    get events_new_url
    assert_response :success

    assert_difference "Event.count", 1 do
      post events_url, params: { event: {
        name: "New Race", activity_type: [ "cycling" ], category: "race",
        description: "d", location_description: "loc",
        start_date: "2026-05-01", end_date: "2026-05-02"
      } }
    end
    assert_equal users(:two).id, Event.order(:created_at).last.user_id
  end

  # --- destroy: creator or admin only ---
  test "creator can delete own event" do
    sign_in_as(users(:two)) # owns events(:two)
    assert_difference "Event.count", -1 do
      delete event_url(events(:two))
    end
  end

  test "non-creator cannot delete" do
    sign_in_as(users(:one))
    assert_no_difference "Event.count" do
      delete event_url(events(:two))
    end
    assert_redirected_to events_path
  end

  test "admin can delete any event" do
    post admin_login_url, params: { email: "admin@example.com", password: "password123" }
    assert_difference "Event.count", -1 do
      delete event_url(events(:two))
    end
  end
end
