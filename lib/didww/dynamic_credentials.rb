# frozen_string_literal: true
# Override client getters to use request-specific mode and api_key

module DIDWW
  module Client
    class << self
      def api_key
        RequestStore.store['api_key']
      end

      def api_mode
        RequestStore.store['api_mode']&.to_sym || DEFAULT_MODE
      end

      def api_base_url
        ENV['DIDWW_API_URL'] || BASE_URLS[api_mode]
      end
    end
  end
end
