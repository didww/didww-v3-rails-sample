class AvailableDidsController < DashboardController

  private

  def countries
    @countries ||= DIDWW::Resource::Country.where(is_available: true).all
  end

  def initialize_api_config
    super.merge({
      resource_type: :available_dids,
      includes: [
          :did_group,
          :'did_group.stock_keeping_units',
          :'did_group.country',
          :'did_group.city',
          :'did_group.region',
          :'did_group.did_group_type'
      ],
      allowed_filters: [
          :'did_group.id',
          :'did_group.needs_registration',
          :'country.id',
          :'region.id',
          :'city.id',
          :number_contains,
          'did_group_type.id': []
      ],
      have_sorting: false
    })
  end

end
