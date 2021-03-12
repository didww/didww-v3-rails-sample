# frozen_string_literal: true
module DynamicForms
  class CitiesController < BaseController
    def select
      @cities = resources if sanitized_filters.present?
      render '_select'
    end

    private

    def initialize_api_config
      super.merge({
        allowed_filters: %w( country.id region.id is_available )
      })
    end

  end
end
