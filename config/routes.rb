Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "api/v1/users", :confirmations => "users/confirmations" }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  api_version(:module => "Api/V1", :header => {:name => "Accept", :value => "application/vnd.versionist_api.v1+json"}) do
    post "sign_in" => "users#sign_in"
    resources :users do
      collection do
        get :user_profile
        get :fetch_qr
        get :enable_two_factor_authentication
        get :disable_two_factor_authentication
      end
    end

  end
end
