class Api::BaseController < ApplicationController
  before_action :enforce_json_format
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_v1_user!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def enforce_json_format
    request.format = :json
  end

  # NOTE: This method is used to enforce consistency in the JSON API responses.
  def generic_render(data: {}, message: nil, code: nil, status: nil, **custom_params)
    render json: custom_params.merge({
      message: message || "success",
      data: data
    }), status: status || :ok
  end

  def record_not_found
    generic_render(message: "Record not found", status: :not_found)
  end
end
