# frozen_string_literal: true
# Hard-code countries with regions

module DIDWW
  module Resource
    class Country < Base
      COUNTRIES_WITH_REGIONS = %w(US CA).freeze
      def has_regions?
        self[:iso].in? COUNTRIES_WITH_REGIONS
      end
    end
  end
end
