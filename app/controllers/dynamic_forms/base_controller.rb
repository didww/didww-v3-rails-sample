# frozen_string_literal: true
module DynamicForms
  class BaseController < ::DashboardController
    layout false

    private

    def default_sorting_column
      :name
    end

    def default_sorting_direction
      :asc
    end

    def initialize_api_config
      super.merge({
        resource_type: controller_name,
        per_page_default: 1000
      })
    end

  end
end
