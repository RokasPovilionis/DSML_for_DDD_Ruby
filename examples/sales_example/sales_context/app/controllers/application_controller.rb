# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_standard_error

  private

  def handle_standard_error(exception)
    render json: { error: exception.message }, status: :internal_server_error
  end
end
