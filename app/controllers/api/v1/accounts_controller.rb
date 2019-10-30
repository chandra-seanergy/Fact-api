class Api::V1::AccountsController < ApplicationController
  before_action :authenticate_request!
  before_action :validate_username, only: [:change_username]
  before_action :validate_password, only: [:delete_account]
  # Change User's username
  def change_username
    if @current_user.update(username: params[:user][:username])
      render json: {status: 200, message: "Username successfully changed."}
    else
      render json: {status: 500, message: @current_user.errors.full_messages}
    end
  end

  # Delete User Account from Database
  def delete_account
    if @current_user.destroy
      render json: {status: 200, message: "Account scheduled for removal."}
    else
      render json: {status: 500, message: @user.errors.full_messages}
    end
  end

  private
  # Validate Username Existance in Database to avoid duplicacy
  def validate_username
    @user = User.find_for_database_authentication(username: params[:user][:username])
    render json: {status: 500, message: "Username already exist."} if @user
  end

  # Validate password at the time of delete account
  def validate_password
    render json: {status: 500, message: "Invalid Password."} unless
    @current_user.valid_password?(params[:user][:password])
  end
end
