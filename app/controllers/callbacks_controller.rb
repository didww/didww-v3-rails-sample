class CallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  # curl -v -X POST "localhost:3000/callbacks?channel_name=notifications_28191f9ef5da88cf3064046270f982ca&message=hello"
  def create
    process_callback
  end

  def index
    process_callback
  end

  private

  def process_callback
    channel_name = params[:channel_name] # "notifications_#{current_user.session_id}"
    message = params[:message]

    ActionCable.server.broadcast(channel_name, { message: message })
    head 204
  end
end
