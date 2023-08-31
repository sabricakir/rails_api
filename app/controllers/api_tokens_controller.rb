class ApiTokensController < ApplicationController
  def index
    @api_tokens = Current.user.api_tokens.order(created_at: :desc)
  end

  def create
    api_token = Current.user.api_tokens.create!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend(
          'api_tokens',
          partial: 'api_tokens/api_token',
          locals: { api_token: }
        )
      end
    end
  end

  def update
    api_token = ApiToken.find(params[:id])
    api_token.update(active: false)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          api_token,
          partial: 'api_tokens/api_token',
          locals: { api_token: }
        )
      end
    end
  end

  def destroy
    api_token = ApiToken.find(params[:id])
    api_token.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(
          api_token
        )
      end
    end
  end
end
