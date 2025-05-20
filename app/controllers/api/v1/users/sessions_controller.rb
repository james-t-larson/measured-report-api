# frozen_string_literal: true

class Api::V1::Users::SessionsController < Api::BaseController
  include Devise::Controllers::Helpers

  respond_to :json
  skip_before_action :authenticate_api_v1_user!, only: [ :create ]

  def new
    # By default devise redirects to the registration page on auth failure.
    # This crashes the app if it's not defined.
    # This is disabled, but this also acts as a fallback
    render json: { error: "Unauthorized access" }, status: :unauthorized
  end

  def create
    user = User.find_by(email: params.dig(:user, :email))
    unless user
      return render json: { error: "Looks like you don't have an account. If you would like one, please contact support for an invite" }, status: :unauthorized
    end

    unless user.valid_password?(params.dig(:user, :password))
      return render json: { error: "Wrong password" }, status: :unauthorized
    end

    sign_in(session_scope, user)
    render json: { message: "Logged in", user: user }, status: :ok
  end

  def destroy
    sign_out(session_scope)
  end

  protected

  def session_scope
    :api_v1_user
  end

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
