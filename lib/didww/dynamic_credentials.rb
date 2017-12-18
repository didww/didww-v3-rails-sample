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
    end
  end
end
