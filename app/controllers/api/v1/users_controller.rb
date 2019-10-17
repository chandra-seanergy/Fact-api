require 'rqrcode_png'
class Api::V1::UsersController < ApplicationController
    before_action :authenticate_request!, except: [:create, :login, :verify_otp]
    before_action :find_user, only: [:login, :verify_otp]
    before_action :validate_password, only: [:login]

    def create
      user = User.new(user_params)
      unless user.save
        render json: {status: 500, message: user.errors.full_messages}
      else
        render json: {status: 201, message: "Registered Successfully", user: payload(user)}
      end
    end

    def login
      if @user.otp_module_disabled?
          render json: {status: 200, message: "Login Successfully", user: payload(@user)}
      else
         render json: {status: 200, message: "Enter OTP"}
      end
    end

    def verify_otp
      if  params[:user][:otp_code].size > 0 && @user.authenticate_otp(params[:user][:otp_code], drift: 60)
        render json: {status: 200, message: "Login Successfully.", user: payload(@user)}
      else
        render json: {status: 500, message: 'Invalid OTP'}
      end
    end

    def user_profile
      render json: {user: @current_user}
    end

    private
    def user_params
      params.require(:user).permit(:name, :email, :password, :username)
    end

    def payload(user)
      return nil unless user and user.id
      {
        auth_token: JsonWebToken.encode({user_id: user.id}),
        user: user
      }
    end

    def find_user
      @user = User.find_for_database_authentication(email: params[:user][:credential]) ||
            User.find_for_database_authentication(username: params[:user][:credential])
      render json: {status: 500, message: "No record found."} unless @user
    end

    def validate_password
      render json: {status: 500, message: "Invalid Login or Password."} unless
        @user.valid_password?(params[:user][:password])
    end
end
