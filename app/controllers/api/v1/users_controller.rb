require 'rqrcode_png'
class Api::V1::UsersController < ApplicationController
    before_action :authenticate_request!, except: [:create, :sign_in]
    # before_action :find_user, only: [:enable_two_factor_authentication, :disable_two_factor_authentication]

    def create
      @user = User.new(user_params)
      if @user.save
        render json: {status: 201, message: "Registered Successfully", user: payload(@user)}
      else
        render json: {status: 500, message: @user.errors.full_messages}
      end
    end

    def sign_in
      @user = User.find_for_database_authentication(email: params[:user][:email])
      if @user && @user.otp_module_disabled?
        validate_password(@user, params[:user][:password])
      elsif @user && @user.otp_module_enabled? && @user.valid_password?(password)
        render json: {status: 200, message: "Enter OTP", user: payload(user)}
      end
    end

    def verify_otp
      if params[:user][:otp_code].size > 0
        if @current_user.authenticate_otp(params[:user][:otp_code], drift: 60)
          render json: {status: 200, message: "Login Successfully.", user: payload(user)}
        else
          render json: {status: 500, message: 'Invalid OTP'}
        end
      else
        render json: {status: 500, message: 'Your account needs to supply a token'}
      end
    end

    def user_profile
      render json: {user: @current_user}
    end

    def fetch_qr
      qrcode = RQRCode::QRCode.new(@current_user.provisioning_uri, size: 10, level: :h )
      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
      )
  		File.open(Rails.root.join("public/#{@current_user.id}.png"), 'wb'){|f| f.write png }
  		image = Cloudinary::Uploader.upload(Rails.root.join("public/#{@current_user.id}.png"))
  		File.delete("./public/#{@current_user.id}.png")
  		qrcode = image.as_json(only: ["public_id", "url"])
      render json: {status: 200, message: "QR fetched", qr: qrcode}
    end

    def enable_two_factor_authentication
      if @current_user.authenticate_otp(params[:user][:otp_code], drift: 60)
        @current_user.otp_module_enabled!
        render json: {status: 200, message: "Two Factor Authentication Enabled"}
      else
        render json: {status: 500, message: 'Two Factor Authentication could not be enabled'}
      end
    end

    def disable_two_factor_authentication
      if @current_user.authenticate_otp(params[:user][:otp_code], drift: 60)
        @current_user.otp_module_disabled!
        render json: {status: 200, message: "Two Factor Authentication Disabled"}
      else
        render json: {status: 500, message: 'Two Factor Authentication could not be disabled'}
      end
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

    def validate_password(user, password)
      if user.valid_password?(password)
        render json: {status: 200, message: "Login Successfully", user: payload(user)}
      else
        render json: {status: 500, message: 'Invalid Username/Password'}
      end
    end
end
