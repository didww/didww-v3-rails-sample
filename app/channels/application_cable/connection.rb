# frozen_string_literal: true
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if session[:api_key].present?
        Rails.logger.info { "Connected to WS #{session[:session_id]}" }
        OpenStruct.new(session_id: session[:session_id])
      else
        reject_unauthorized_connection
      end
    end

    def session
      return @session if defined?(@session)

      session_key = Rails.application.config.session_options[:key]
      @session = cookies.encrypted[session_key]&.symbolize_keys || {}
    end
  end
end
