# frozen_string_literal: true
class CallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_request, only: [:create, :index]

  INVALID_SIGNATURE_ERROR = 'Request should be from DIDWW'
  SIGNATURE_HEADER = "HTTP_#{DIDWW::Callback::RequestValidator::HEADER.underscore.upcase}"

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
    "notifications_#{params[:session_id]}"
  end

  def check_request
    api_key = DataEncryptor.decrypt params[:opaque]
    validator = DIDWW::Callback::RequestValidator.new(api_key)
    uri = request.original_url
    signature = request.headers[SIGNATURE_HEADER]
    payload = params.to_unsafe_h.deep_symbolize_keys.except(:opaque, :session_id, :controller, :action)
    unless validator.validate(uri, payload, signature)
      logger.error { "invalid signature uri=#{uri.inspect} payload=#{payload.inspect} signature=#{signature}" }
      render status: 422, json: { message: INVALID_SIGNATURE_ERROR }
    end
  rescue DataEncryptor::Error => e
    logger.error { "#{e.class}: #{e.message}\nopaque=#{params[:opaque].inspect}" }
    render status: 422, json: { message: INVALID_SIGNATURE_ERROR }
  end
end
