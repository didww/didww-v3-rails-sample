# frozen_string_literal: true
class CoverageController < DashboardController

  private

  def countries
    @countries ||= DIDWW::Resource::Country.where(is_available: true).all
  end

  def default_sorting_column
    sanitized_filters['country.id'] ? :area_name : :'country.name'
  end

  def default_sorting_direction
    :asc
  end

  def initialize_api_config
    super.merge({
      resource_type: :did_groups,
      includes: [
        :country,
        :city,
        :region,
        :did_group_type,
        :stock_keeping_units,
        :requirement
      ],
      allowed_filters: %w(
        features
        country.id
        region.id
        city.id
        is_metered
        allow_additional_channels
        needs_registration
        is_available
        available_dids_enabled
      ) << {
        'id': [],
        'did_group_type.id': [],
        'features': []
      }
    })
  end

end
