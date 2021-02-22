class IdentitiesController < DashboardController
  before_action :assign_params, only: [:create, :update]

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

  def assign_params
    resource.attributes = resource_params
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
      :identity_type
    )
  end

  def apply_sorting(collection)
    collection
  end

  def default_sorting_direction
    :asc
  end
end
