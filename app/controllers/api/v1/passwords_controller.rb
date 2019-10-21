class Api::V1::PasswordsController < ApplicationController
  # before_action :authenticate_request!, except: [:forgot_password]
  before_action :find_user, only: [:forgot_password]
  before_action :token_validate, only: [:reset_password]

  def forgot_password
    @user.send_reset_password_instructions
    render json: {status: 200, message: "Password reset instruction sent to your email"}
  end

  def reset_password
    if @user.reset_password!(params[:password])
      render json: {status: 200, message: "Password updated"}
    else
      render json: {status: 500, message: @user.errors.full_messages}
    end
  end

  private

  def find_user
    @user = User.find_for_database_authentication(email: params[:user][:email])
    render json: {status: 500, message: "No record found."} unless @user
  end

  def token_validate
    return render json: {error: 'Token not present'} if params[:token].blank?
    token = params[:token].to_s
    @user = User.find_by(reset_password_token: token)
    render json: {status: 500, message: "Link not valid or expired. Try generating a new link."} unless @user.present? && @user.password_token_valid?
  end
end
