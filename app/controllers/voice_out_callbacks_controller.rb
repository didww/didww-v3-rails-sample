# frozen_string_literal: true

class VoiceOutCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_request, only: [:create, :index]

  INVALID_SIGNATURE_ERROR = 'Request should be from DIDWW'
  SIGNATURE_HEADER = "HTTP_#{DIDWW::Callback::RequestValidator::HEADER.underscore.upcase}"

  def create
    ActionCable.server.broadcast(
      channel_name,
      title: 'Voice out trunk status were changed',
      message: channel_message
    )
    head 204
  end

  private

  def channel_name
    "notifications_#{params[:session_id]}"
  end

  def channel_message
    render_to_string partial: 'voice_out_callbacks/events',
                     locals: { callback_payload: callback_payload }
  end

  def callback_payload
    # When payload is a JSON array Rails wraps it into `_json` key.
    @callback_payload ||= params.to_unsafe_h[:_json].map(&:deep_symbolize_keys)
  end

  def check_request
    api_key = DataEncryptor.decrypt params[:opaque]
    validator = DIDWW::Callback::RequestValidator.new(api_key)
    uri = request.original_url
    signature = request.headers[SIGNATURE_HEADER]
    unless validator.validate(uri, callback_payload, signature)
      logger.error { "invalid signature uri=#{uri.inspect} payload=#{callback_payload.inspect} signature=#{signature}" }
      render status: 422, json: { message: INVALID_SIGNATURE_ERROR }
    end
  rescue DataEncryptor::Error => e
    logger.error { "#{e.class}: #{e.message}\nopaque=#{params[:opaque].inspect}" }
    render status: 422, json: { message: INVALID_SIGNATURE_ERROR }
  end
end
