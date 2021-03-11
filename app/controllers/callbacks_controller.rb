class CallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :check_request, only: [:create]

  # curl -v -X POST "localhost:3000/callbacks?channel_name=notifications_28191f9ef5da88cf3064046270f982ca&message=hello"
  def create
    process_callback
  end

  def index
    process_callback
  end

  private

  def process_callback
    ActionCable.server.broadcast(channel_name, params)
    head 204
  end

  private

  def channel_name
    params[:session_id] ? "notifications_#{params[:session_id]}" : params[:channel_name]# "notifications_#{current_user.session_id}"
  end

  def check_request
    validator = DIDWW::Callback::RequestValidator.new(session[:api_key])
    uri = request.original_url
    signature = request.headers['HTTP_X_DIDWW_SIGNATURE']
    unless validator.validate(uri, params, signature)
      render status: 422, json: { message: 'Request should be from DIDWW' }
    end
  end
end
