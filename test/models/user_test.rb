require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with only a line_user_id" do
    user = User.new(line_user_id: "U_new")
    assert user.valid?
  end

  test "valid with email and password" do
    user = User.new(email: "someone@example.com", password: "password123")
    assert user.valid?
  end

  test "invalid without any identity" do
    user = User.new(display_name: "Nobody")
    assert_not user.valid?
  end

  test "email-only account requires a password on create" do
    user = User.new(email: "nopass@example.com")
    assert_not user.valid?
  end

  test "password must be at least 8 characters" do
    user = User.new(email: "short@example.com", password: "short")
    assert_not user.valid?
  end

  test "line_user_id must be unique" do
    user = User.new(line_user_id: users(:one).line_user_id)
    assert_not user.valid?
  end

  test "email is normalized and unique" do
    user = User.new(email: "  ADMIN@Example.com ", password: "password123")
    assert_equal "admin@example.com", user.email
    assert_not user.valid?
  end

  test "admin defaults to false" do
    assert_not User.new(line_user_id: "U_x").admin
  end
end
