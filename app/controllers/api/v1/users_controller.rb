require 'rqrcode_png'
class Api::V1::UsersController < ApplicationController
    before_action :authenticate_request!, except: [:create, :login, :verify_otp, :show,
        :resend_confirmation]
    before_action :find_user, only: [:login, :verify_otp]
    before_action :validate_password, only: [:login]
    before_action :confirmed_user, only: [:login]

    # Register and create user in database
    def create
      user = User.new(user_params)
      unless user.save
        render json: {status: 500, message: user.errors.full_messages}
      else
        render json: {status: 201, message: "Registered Successfully", user: payload(user)}
      end
    end

    # Login User API
    def login
      if @user.otp_module_disabled?
        render json: {status: 200, message: "Login Successfully", user: payload(@user), otp_module: "disabled"} #login successfully if dual authentication disbled
      else
        render json: {status: 200, message: "Enter OTP", otp_module: "enabled"} # Dispaly OTP screen if two factor authentication enabled 
      end
    end

    # Verify OTP if two factor authentication enabled 
    def verify_otp
      user_otp = params[:user][:otp_code]
      if  user_otp.size > 0 && @user.authenticate_otp(user_otp, drift: 60)
        render json: {status: 200, message: "Login Successfully.", user: payload(@user)}
      else
        render json: {status: 500, message: 'Invalid OTP'}
      end
    end

    # Redirect to confirmation page once the email is confirmed by user
    def show
       @user = User.confirm_by_token(params[:confirmation_token])
       user_errors = @user.errors
       if user_errors.empty?
        redirect_to "#{VIEW_DOMAIN}?confirmation=mail"
       else
        redirect_to "#{VIEW_DOMAIN}?message=#{user_errors.full_messages}"
       end
    end

    # Resend confirmation mail for email confirmation 
    def resend_confirmation
      @user = User.find_by(email: params[:user][:email])
      render json: {status: 404, message: "No record found."} unless @user
      if @user.confirmed_at.present?
        render json: {status: 200, message: "This account has already been confirmed"}
      else
        @user.resend_confirmation_instructions
        render json: {status: 200, message: "Your request has been received. A new confirmation email has been sent."}
      end
    end

    # Display logged-in user Details
    def user_profile
      render json: {user: @current_user}
    end

    # Update User profile attributes
    def update_profile
      user_avatar = params[:user][:avatar]
      @current_user.avatar = user_avatar if !user_avatar.nil? and File.exist?(user_avatar)
      if @current_user.update(profile_params)
        render json: {status: 200, message: "Profile Updated Successfully.", avatar: @current_user.avatar.url}
      else
        render json: {status: 500, message: @current_user.errors.full_messages}
      end
    end

    private
    # Allow strong parameters to be validated at time of user registration
    def user_params
      params.require(:user).permit(:name, :email, :password, :username)
    end

    # Allow strong parameters to be validated at the time of profile update
    def profile_params
      params.require(:user).permit(:name, :email, :public_email, :commit_email, :skype, :linkedin, :twitter, :website_url, :location, :organization, :bio, :private_profile, :private_contributions)
    end

    # Return User Data with auth token
    def payload(user)
      return nil unless user and user.id
      {
        auth_token: JsonWebToken.encode({user_id: user.id}),
        user: user
      }
    end

    # Find User on the basis of credentials provided
    def find_user
      user_credentials = params[:user][:credential]
      @user = User.find_for_database_authentication(email: user_credentials) ||
            User.find_for_database_authentication(username: user_credentials)
      render json: {status: 404, message: "Invalid Login or Password."} unless @user
    end

    # Validate password at the time of log in
    def validate_password
      render json: {status: 500, message: "Invalid Login or Password."} unless
      @user.valid_password?(params[:user][:password])
    end

    # Validates if the user logging in has confirmed his mail or not
    def confirmed_user
      render json: {status: 500, message: "Please confirm your email."} unless @user.confirmed?
    end
end
