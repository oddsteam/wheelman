require "net/http"
require "uri"
require "json"

class LineAuthService
  VERIFY_URL = "https://api.line.me/oauth2/v2.1/verify"

  def self.verify(id_token)
    uri = URI(VERIFY_URL)

    res = Net::HTTP.post_form(uri, {
      id_token: id_token,
      client_id: ENV["LINE_CHANNEL_ID"]
    })

    unless res.is_a?(Net::HTTPSuccess)
      # LINE returns JSON error details on 4xx; other failures may not be JSON
      detail = JSON.parse(res.body)["error_description"] rescue nil
      raise StandardError.new("LINE verify failed: #{detail || "HTTP #{res.code}"}")
    end

    body = JSON.parse(res.body)

    if body["error"]
      raise StandardError.new("LINE verify failed: #{body['error_description']}")
    end

    body
  end
end
