class Api::V1::TwoFactorAuthenticationsController < ApplicationController
  before_action :authenticate_request!

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
      resize_gte_to: false)
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
        render json: {status: 500, message: "Invalid two-factor code."}
      end
    end

    def disable_two_factor_authentication
      if @current_user.authenticate_otp(params[:user][:otp_code], drift: 60)
        @current_user.otp_module_disabled!
        render json: {status: 200, message: "Two Factor Authentication Disabled"}
      else
        render json: {status: 500, message: "Invalid two-factor code."}
      end
    end
end
