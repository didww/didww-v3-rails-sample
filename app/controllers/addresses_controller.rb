# frozen_string_literal: true
class AddressesController < DashboardController
  before_action :assign_params, only: [:create, :update]
  before_action only: [:new, :create] do
    identity_id = params[:identity_id] || resource.identity&.id
    identity = identities.find { |i| i.id == identity_id }
    @identity = IdentityDecorator.decorate(identity)
  end

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

  def search_options
    collection = find_collection
    display_name = ->(record) { "#{record.country.name} #{record.address} #{record.description}" }
    options = collection.map do |record|
      { id: record.id, text: display_name.call(record) }
    end
    payload = {
      options: options,
      pagination: {
        current_page: collection.current_page,
        per_page: collection.per_page,
        total_entries: collection.total_entries
      }
    }
    render json: payload
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :addresses,
      decorator_class: AddressDecorator,
      includes: [
        :identity,
        :country,
        :proofs
      ],
      allowed_filters: [
        :'identity.id',
        :'country.id',
        :address_contains,
        :postal_code,
        :city_name_contains
      ]
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
