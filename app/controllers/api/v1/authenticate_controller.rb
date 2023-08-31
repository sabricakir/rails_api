class Api::V1::AuthenticateController < ActionController::Base
  before_action :authenticate_user!

  attr_reader :current_user, :current_api_token

  def authenticate_user!
    authenticate_user_from_token || render_unauthorized
  end

  private

  def authenticate_user_from_token
    authenticate_with_http_token do |token, _options|
      @current_api_token = ApiToken.where(active: true).find_by(token:)
      @current_user = @current_api_token&.user
    end
  end

  def render_unauthorized
    render json: { error: 'Bad credentials' }, status: :unauthorized
  end
end
