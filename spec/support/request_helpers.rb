module Request
  module AuthenticationHelper
    def json
      JSON.parse(response.body)
    end
    def confirm_and_login_user(user)
      post '/login', params: {
          user: {
              email: user.email,
              password: user.password
          }
      }
      token_from_request = response.headers['Authorization'].split(' ').last
      JWT.decode(token_from_request, Rails.application.credentials.devise_jwt_secret_key, true)
    end
  end
end