class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  # before_action :authenticate_user!
  include ActionController::Serialization
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Devise methods
  def configure_permitted_parameters
    added_attrs = [:email, :name, :mobile]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end