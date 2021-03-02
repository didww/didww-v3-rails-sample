class ProofsController < DashboardController
  before_action :assign_params, only: [:create]

  def create
    if resource.save
      flash[:success] = 'Proof was successfully created.'
      redirect_to identities_path
    else
      render :new
    end
  end

  def destroy
    # if resource.destroy
      flash[:success] = 'Proof was successfully deleted.'
      redirect_to identities_path
    # else
    #   flash[:danger] = 'Failed to delete Proof: ' + resource.errors[:base].join('. ')
    #   redirect_back fallback_location: address_path(resource)
    # end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :proofs,
      includes: [
        :files,
        :proof_type,
        :entity
      ]
    })
  end

  def assign_params
    resource.attributes = resource_params.except(:country_id, :identity_id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:address).permit(:is_expired)
  end

  def apply_sorting(collection)
    collection
  end

  def default_sorting_direction
    :asc
  end
end
