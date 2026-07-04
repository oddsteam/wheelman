class SessionsController < ApplicationController
  skip_before_action :require_login

  def destroy
    reset_session
    redirect_to login_path
  end
end
