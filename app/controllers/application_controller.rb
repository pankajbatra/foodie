class ApplicationController < ActionController::API
  respond_to :json
  include Response
  include ExceptionHandler
  include ActionController::Serialization
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Devise methods
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: [:email, :name, :mobile, role_names: []]
    devise_parameter_sanitizer.permit :account_update, keys: [:email, :name, :mobile]
  end
end