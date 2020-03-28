class ApplicationController < ActionController::API
  respond_to :json
  include Response
  include ExceptionHandler
  include ActionController::Serialization
  before_action :configure_permitted_parameters, if: :devise_controller?
  serialization_scope :current_user

  protected

  # Devise methods
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: [:email, :name, :mobile, role_names: []]
    devise_parameter_sanitizer.permit :account_update, keys: [:email, :name, :mobile]
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'application/json' }
    end
  end
end