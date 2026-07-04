ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module LineAuthStubbing
  # Temporarily replace LineAuthService.verify for the duration of the block.
  # `result` can be a profile Hash or a callable (e.g. to raise).
  def stub_line_verify(result)
    original = LineAuthService.method(:verify)
    LineAuthService.define_singleton_method(:verify) do |token|
      result.respond_to?(:call) ? result.call(token) : result
    end
    yield
  ensure
    LineAuthService.define_singleton_method(:verify, original)
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    include LineAuthStubbing

    # Log in as a LINE user by exercising the real auth endpoint with
    # LineAuthService stubbed to return this user's profile.
    def sign_in_as(user)
      profile = {
        "sub" => user.line_user_id,
        "name" => user.display_name,
        "picture" => user.picture_url
      }
      stub_line_verify(profile) do
        post "/auth/line_liff", params: { id_token: "test.id.token" }, as: :json
      end
    end
  end
end
