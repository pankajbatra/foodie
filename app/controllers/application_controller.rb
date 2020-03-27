class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  # before_action :authenticate_user!
  include ActionController::Serialization
end