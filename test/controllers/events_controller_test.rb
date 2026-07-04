require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when not authenticated" do
    get events_url
    assert_redirected_to login_path

    get events_new_url
    assert_redirected_to login_path
  end

  test "should get index when logged in" do
    sign_in_as(users(:one))
    get events_url
    assert_response :success
  end

  test "should get new when logged in" do
    sign_in_as(users(:one))
    get events_new_url
    assert_response :success
  end

  test "logout clears the session" do
    sign_in_as(users(:one))
    get events_url
    assert_response :success

    delete logout_url
    assert_redirected_to login_path

    get events_url
    assert_redirected_to login_path
  end
end
