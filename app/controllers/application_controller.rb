class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  # @note This method is used to enforce consistency in the JSON API responses.
  def generic_render(data: {}, message: nil, code: nil, status: nil, **custom_params)
    render json: custom_params.merge({
      message: message || "Success",
      code: code || 0,
      data: data
    }), status: status || :ok
  end

  def record_not_found
    generic_render(message: "Record not found", status: :not_found)
  end
end
