class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_validation_error

  private

  def handle_validation_error(error)
    render json: { error: error.message }, status: :bad_request
  end
end
