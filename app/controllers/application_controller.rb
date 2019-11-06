class ApplicationController < ActionController::API
  attr_reader :current_user

  protected
  # Authenticate and find User on the basis of token provided
  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
    @current_user = User.find(auth_token[:user_id])
    rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end
  
  private
  # Find auth token in headers
  def http_token
    request_header = request.headers['Authorization']
    @http_token ||= if request_header.present?
      request_header.split(' ').last
    end
  end

  # Decode Auth Token recieved
  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  end

  # Find user ID prensent in Auth token
  def user_id_in_token?
    http_token && auth_token && auth_token[:user_id].to_i
  end
end
