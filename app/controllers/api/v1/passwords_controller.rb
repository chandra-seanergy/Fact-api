class Api::V1::PasswordsController < ApplicationController
  # before_action :authenticate_request!, except: [:forgot_password]
  before_action :find_user, only: [:forgot_password]
  # before_action :reset_password_token, only: [:reset_password]

  def forgot_password
    @user.send_reset_password_instructions
    render json: {status: 200, message: "Password reset instruction sent to your email"}
  end

  # def reset_password
  #   token = params[:user][:token].to_s
  #       if token.blank?
  #         return render json: {error: 'Token not present'}
  #       end
  #       @user = User.find_by(reset_password_token: token)
  #       if @user.present? && @user.reset_password_period_valid?
  #         if @user.reset_password(params[:user][:password], params[:user][:password_confirmation])
  #           render json: {status: 200, message: "Password updated"}
  #         else
  #           render json: {status: 500, message: @user.errors.full_messages}
  #         end
  #       else
  #         render json: {status: 500, message: "Link not valid or expired. Try generating a new link."}
  #       end
  #     end

  def reset_password
    token = params[:user][:token].to_s
    render json: {error: 'Token not present'} unless token.present?
     @user = User.find_by(reset_password_token: token)
     render json: {error: 'Token not present'} unless token.present? unless @user.reset_password_period_valid?
     if @user.reset_password(params[:user][:password], params[:user][:password_confirmation])
       render json: {status: 200, message: "Password updated"}
    else
      render json: {status: 500, message: "Link not valid or expired. Try generating a new link."}
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
