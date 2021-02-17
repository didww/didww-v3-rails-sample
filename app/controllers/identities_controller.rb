class IdentitiesController < DashboardController

  private

  def initialize_api_config
    super.merge({
      resource_type: :identities,
      includes: [
        :country,
        :proofs,
        :addresses,
        :permanent_documents
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
