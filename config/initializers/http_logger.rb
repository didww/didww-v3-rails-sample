# frozen_string_literal: true
if Rails.env.development?
  HttpLogger.logger = Logger.new($stdout)
  HttpLogger.log_headers = true
end
