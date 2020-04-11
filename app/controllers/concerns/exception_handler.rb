module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |exception|
      json_response({ message: exception.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      json_response({ message: exception.message }, :unprocessable_entity)
    end

    rescue_from StandardError do |exception|
      logger.error exception.message
      logger.error exception.backtrace.join("\n")
      json_response({ message: exception.message }, :unprocessable_entity)
    end
  end
end
