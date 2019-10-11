# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

 Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
     origins 'localhost:3000'

     resource '/api/v1/*',
       headers: ['Accept','Content-Type','Authorization']
       methods: [:get, :post, :put, :patch, :delete]
       # if: proc { |env| env['HTTP_HOST'] == 'api.example.com' }
       if: proc { |env| env['HTTP_HOST'] == 'localhost:3000' }
   end
 end
