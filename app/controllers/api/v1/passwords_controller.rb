class Api::V1::PasswordsController < ApplicationController
  # before_action :authenticate_request!, except: [:forgot_password]
  before_action :find_user, only: [:forgot_password]
  before_action :reset_password_token, only: [:reset_password]

  def forgot_password
    @user.send_reset_password_instructions
    render json: {status: 200, message: "Password reset instruction sent to your email"}
  end

  def reset_password
    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
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

  def reset_password_token
    return render json: {error: 'Token not present'} if params[:token].blank?
    @user = User.find_by(reset_password_token: params[:token])
    render json: {status: 500, message: "Link not valid or expired. Try generating a new link."} unless @user &&
      @user.password_token_valid?
  end
end
