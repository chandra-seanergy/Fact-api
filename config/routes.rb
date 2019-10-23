Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "api/v1/users", :confirmations => "api/v1/users" }
  # get :resend_confirmation

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  api_version(:module => "Api/V1", :header => {:name => "Accept", :value => "application/vnd.versionist_api.v1+json"}) do
    resources :users do
      collection do
        post :login
        get :user_profile
        post :verify_otp
        get :resend_confirmation
      end
    end
    resources :two_factor_authentications do
      collection do
        get :fetch_qr
        post :enable_two_factor_authentication
        post :disable_two_factor_authentication
      end
    end
    resources :passwords do
      collection do
        post :forgot_password
         put :reset_password
      end
    end
    resources :accounts do
      collection do
        post :validate_username
        delete :delete_account
        patch :change_username
      end
    end
    resources :groups
  end
end
