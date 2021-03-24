# frozen_string_literal: true
class IdentitiesController < DashboardController
  before_action :assign_params, only: [:create, :update]

  def new
    resource.identity_type = params[:identity_type]
  end

  def create
    if resource.save
      flash[:success] = 'Identity was successfully created.'
      redirect_to identity_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = 'Identity was successfully updated.'
      redirect_to identity_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Identity was successfully deleted.'
      redirect_to identities_path
    else
      flash[:danger] = 'Failed to delete Identity: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: identity_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :identities,
      decorator_class: IdentityDecorator,
      includes: [
        :country,
        :'proofs.proof_type',
        :addresses,
        :'addresses.country',
        :permanent_documents
      ],
      allowed_filters: [
        :first_name_contains,
        :last_name_contains,
        :description_contains,
        :company_name_contains,
        :identity_type
      ]
    })
  end

  def assign_params
    country = DIDWW::Resource::Country.load(id: resource_params[:country_id])
    resource.attributes = resource_params.except(:country_id)
    resource.relationships.country = country
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:identity).permit(
      :first_name,
      :last_name,
      :phone_number,
      :id_number,
      :birth_date,
      :company_name,
      :company_reg_number,
      :vat_id,
      :description,
      :personal_tax_id,
      :identity_type,
      :country_id,
      :external_reference_id
    )
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end
end
