if @user && @user.otp_module_disabled? && @user.valid_password?(params[:user][:password])
  json.status 200
  json.message "Login Successfully"
  json.user @user_payload
elsif @user && @user.otp_module_enabled? && @user.valid_password?(password)
  json.status 200
  json.message "Enter OTP"
else
  json.status 500
  json.message "Invalid credentials."
end
