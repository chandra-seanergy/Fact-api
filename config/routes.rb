Rails.application.routes.draw do
  # devise_for :users, :controllers => { :registrations => "api/v1/users", :confirmations => "users/confirmations" }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  api_version(:module => "Api/V1", :header => {:name => "Accept", :value => "application/vnd.versionist_api.v1+json"}) do
    resources :users do
      collection do
        post :login
        get :user_profile
        post :verify_otp
      end
    end
    resources :two_factor_authentications do
      collection do
        get :fetch_qr
        post :enable_two_factor_authentication
        post :disable_two_factor_authentication
      end
    end
  end
end
