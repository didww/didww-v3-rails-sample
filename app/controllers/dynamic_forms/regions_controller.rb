module DynamicForms
  class RegionsController < BaseController
    def select
      @regions = resources if sanitized_filters.present?
      render '_select'
    end

    private

    def initialize_api_config
      super.merge({
        allowed_filters: %w( country.id )
      })
    end

  end
end
