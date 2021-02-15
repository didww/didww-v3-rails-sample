class RequirementsController < DashboardController

  private

  def initialize_api_config
    super.merge({
      resource_type: :requirements,
      includes: [
        :country,
        :did_group_type,
        :personal_permanent_document,
        :business_permanent_document,
        :personal_onetime_document,
        :business_onetime_document,
        :personal_proof_types,
        :business_proof_types,
        :address_proof_types
      ]
    })
  end

  def default_sorting_column
    # :personal_proof_qty
    :created_at
  end

  def default_sorting_direction
    :asc
  end
end
