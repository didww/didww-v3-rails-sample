class ProofsController < DashboardController
  before_action :assign_params, only: [:create]

  def create
    if resource.save
      flash[:success] = 'Proof was successfully created.'
      render status: 201, js: "window.location = '#{identity_path(resource_params[:identity_id])}'"
    else
      render status: 422, json: { errors: resource.errors.messages }
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Proof was successfully deleted.'
      redirect_to identity_path(resource)
    else
    #   flash[:danger] = 'Failed to delete Proof: ' + resource.errors[:base].join('. ')
    #   redirect_back fallback_location: address_path(resource)
    end
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
    proof_type = DIDWW::Resource::ProofType.load(id: resource_params[:proof_type_id])
    entity = DIDWW::Resource::Identity.load(id: resource_params[:identity_id])
    file_ids = DIDWW::Resource::EncryptedFile.upload(resource_params[:files], resource_params[:encryption_fingerprint])
    files = file_ids.map { |id| DIDWW::Resource::EncryptedFile.load(id: id) }
    resource.relationships.proof_type = proof_type
    resource.relationships.entity = entity
    resource.relationships.files = files
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:proof).permit(:proof_type_id, :identity_id, :encryption_fingerprint, files: [])
  end

  def apply_sorting(collection)
    collection
  end

  def default_sorting_direction
    :asc
  end
end
