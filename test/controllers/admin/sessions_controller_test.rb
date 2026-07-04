require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "shows login form" do
    get admin_login_url
    assert_response :success
  end

  test "rejects wrong password" do
    post admin_login_url, params: { email: "admin@example.com", password: "wrong-password" }
    assert_response :unprocessable_entity
  end

  test "rejects a non-admin even with correct password" do
    User.create!(email: "member@example.com", password: "password123")
    post admin_login_url, params: { email: "member@example.com", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "logs in an admin and redirects to avo" do
    post admin_login_url, params: { email: "admin@example.com", password: "password123" }
    assert_redirected_to "/avo"
  end
end
