# frozen_string_literal: true

module DynamicForms
  class NanpaPrefixesController < BaseController
    def select
      @nanpa_prefixes = resources if sanitized_filters.present?
      render '_select'
    end

    private

    def initialize_api_config
      super.merge({
                    allowed_filters: %w(country.id region.id),
                    have_sorting: false,
                    per_page_default: 100
                  })
    end
  end
end
