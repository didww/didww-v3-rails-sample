# frozen_string_literal: true
if Rails.env.development?
  HttpLogger.configure do |c|
    c.logger = Logger.new($stdout)
    c.log_headers = true
  end
end
