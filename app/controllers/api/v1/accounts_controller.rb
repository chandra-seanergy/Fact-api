class Api::V1::AccountsController < ApplicationController
  before_action :authenticate_request!
  before_action :validate_username, only: [:change_username]

  def change_username
    if @current_user.update(username: params[:user][:username])
      render json: {status: 200, message: "Username successfully changed."}
    else
      render json: {status: 500, message: @current_user.errors.full_messages}
    end
  end

  def delete_account
    if @current_user.destroy
      render json: {status: 200, message: "Account scheduled for removal."}
    else
      render json: {status: 500, message: @user.errors.full_messages}
    end
  end

  private
  def validate_username
    @user = User.find_for_database_authentication(username: params[:user][:username])
    render json: {status: 500, message: "Username already exist."} if @user
  end
end
