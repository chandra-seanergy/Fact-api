class Api::V1::PasswordsController < ApplicationController
  before_action :find_user, only: [:forgot_password]

  def forgot_password
    @user.send_reset_password_instructions
    render json: {status: 200, message: "Password reset instruction sent to your email."}
  end
  private

  def find_user
    @user = User.find_for_database_authentication(email: params[:user][:email])
    render json: {status: 404, message: "No record found."} unless @user
  end
end
