class AuthController < ApplicationController 
  def line_liff
    id_token = params[:id_token]
 
    return render json: { error: "missing token" }, status: 401 if id_token.blank?

    begin
      data = LineAuthService.verify(id_token)
    rescue => e
      return render json: { error: e.message }, status: 401
    end

    user = User.find_or_initialize_by(line_user_id: data["sub"])
    user.display_name = data["name"]
    user.picture_url = data["picture"]
    user.email = data["email"] if data["email"].present?
    user.save!

    session[:user_id] = user.line_user_id

    render json: { message: "success", user: data }
  end
end