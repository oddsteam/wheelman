require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "rejects missing token" do
    post "/auth/line_liff", params: {}, as: :json
    assert_response :unauthorized
  end

  test "rejects when LINE verification fails" do
    raises = ->(_token) { raise StandardError.new("LINE verify failed: invalid token") }
    stub_line_verify(raises) do
      post "/auth/line_liff", params: { id_token: "bad.token" }, as: :json
    end
    assert_response :unauthorized
  end

  test "creates user and session from a valid token" do
    profile = { "sub" => "U_brand_new", "name" => "New User", "picture" => "https://example.com/p.png" }

    assert_difference "User.count", 1 do
      stub_line_verify(profile) do
        post "/auth/line_liff", params: { id_token: "good.token" }, as: :json
      end
    end
    assert_response :success

    user = User.find_by(line_user_id: "U_brand_new")
    assert_equal "New User", user.display_name
    assert_not user.admin?

    # session works: a protected page now renders
    get events_url
    assert_response :success
  end

  test "reuses existing user on repeat login" do
    user = users(:one)
    assert_no_difference "User.count" do
      sign_in_as(user)
    end
    assert_response :success
  end
end
