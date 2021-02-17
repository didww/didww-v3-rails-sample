class IdentitiesController < DashboardController

  private

  def initialize_api_config
    super.merge({
      resource_type: :identities,
      includes: [
        :identity,
        :country,
        :proofs
      ],
      # allowed_filters: [
      #   :'country.id',
      #   :'did_group_type.id'
      # ]
    })
  end

  def apply_sorting(collection)
    collection
  end

  def default_sorting_direction
    :asc
  end
end
