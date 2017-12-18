class CoverageController < DashboardController

  private

  def default_sorting_column
    sanitized_filters['country.id'] ? :area_name : :'country.name'
  end

  def default_sorting_direction
    :asc
  end

  def initialize_api_config
    super.merge({
      resource_type: :did_groups,
      includes: [:country, :city, :region, :did_group_type, :stock_keeping_units],
      allowed_filters: %w(
        features
        country.id
        region.id
        city.id
        is_metered
        allow_additional_channels
        needs_registration
        is_available
      ) << {
        'id': [],
        'did_group_type.id': [],
        'features': []
      }
    })
  end

end
