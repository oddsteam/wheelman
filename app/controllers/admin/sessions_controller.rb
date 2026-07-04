class Admin::SessionsController < ApplicationController
  skip_before_action :require_login

  rate_limit to: 10, within: 3.minutes, only: :create

  def new
  end

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])

    if user&.admin?
      session[:user_id] = user.id
      redirect_to Avo.configuration.root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end
end
