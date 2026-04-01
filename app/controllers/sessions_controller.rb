class SessionsController < ApplicationController
  protect_from_forgery with: :exception
 
  def line_liff
    id_token = params[:id_token]
 
    return render json: { error: "missing token" }, status: 401 if id_token.blank?

    uri = URI("https://api.line.me/oauth2/v2.1/verify")
    res = Net::HTTP.post_form(uri, {
      id_token: id_token,
      client_id: ENV['LINE_CHANNEL_ID']
    })

    data = JSON.parse(res.body)

    unless data["sub"]
      return render json: { error: "invalid token" }, status: 401
    end

    if data["exp"] && Time.at(data["exp"]) < Time.now
      return render json: { error: "expired token" }, status: 401
    end

    puts data

    render json: {
      message: "ok",
      user: data,
    }
  end
end