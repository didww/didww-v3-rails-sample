class AddressVerificationsController < DashboardController
  private

  def initialize_api_config
    super.merge({
      resource_type: :address_verifications,
      decorator_class: AddressVerificationDecorator,
      includes: [
        :'address.country',
        :'address.identity',
        :dids
      ],
      allowed_filters: [
        :'address.id',
        :'address.identity.id',
        :status
      ]
    })
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end
end
