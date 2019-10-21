class Api::V1::AccountsController < ApplicationController
  before_action :authenticate_request!

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

  def validate_username
    if @current_user.username.eql?(params[:user][:username])
      render json: {message: "disble"}
    else
      render json: {message: "enable"}
    end
  end
end
