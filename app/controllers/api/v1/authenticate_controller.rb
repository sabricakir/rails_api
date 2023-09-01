class Api::V1::AuthenticateController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  protect_from_forgery with: :null_session

  before_action :authenticate_user!
  before_action :check_api_limit
  before_action :log_api_request

  attr_reader :current_user, :current_api_token

  def authenticate_user!
    authenticate_user_from_token || render_unauthorized
  end

  private

  def authenticate_user_from_token
    authenticate_with_http_token do |token, _options|
      @current_api_token = ApiToken.where(active: true).find_by(token:)
      @current_user = @current_api_token&.user
      @current_api_token&.update!(last_used_at: Time.zone.now)
    end
  end

  def render_unauthorized
    render json: { error: 'Bad credentials' }, status: :unauthorized
  end

  def render_not_found_response
    render json: { error: 'Record not found' }, status: :not_found
  end

  def log_api_request
    ApiRequest.create!(
      user: current_user,
      path: request.path,
      method: request.method
    )
    response.set_header('Rails-API-Call-Limit',
                        "#{current_user.api_requests_remaining}/#{User::MAX_API_REQUESTS_PER_30_DAYS}")
  end

  def check_api_limit
    return unless current_user.api_limit_reached?

    render json: { error: 'API limit reached' }, status: :too_many_requests
  end
end
