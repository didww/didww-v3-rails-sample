class AddressesController < DashboardController
  before_action :assign_params, only: [:create, :update]

  def new
    resource.identity_id = params[:identity_id]
  end

  def create
    if resource.save
      flash[:success] = 'Address was successfully created.'
      redirect_to address_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = 'Address was successfully updated.'
      redirect_to address_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Address was successfully deleted.'
      redirect_to identities_path
    else
      flash[:danger] = 'Failed to delete Address: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: address_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :addresses,
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

  def assign_params
    country = DIDWW::Resource::Country.load(id: resource_params[:country_id])
    identity = DIDWW::Resource::Identity.load(id: resource_params[:identity_id])
    resource.attributes = resource_params.except(:country_id, :identity_id)
    resource.relationships.country = country
    resource.relationships.identity = identity
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:address).permit(
      :city_name,
      :postal_code,
      :address,
      :description,
      :identity_id,
      :country_id
    )
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end
end
