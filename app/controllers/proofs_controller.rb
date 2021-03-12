# frozen_string_literal: true
class ProofsController < DashboardController

  def create
    form = ProofForm.new(resource_params)
    if form.save
      flash[:success] = 'Proof was successfully created.'
      render status: 201, js: 'location.reload(true)'
    else
      render status: 422, json: { errors: form.errors.messages }
    end
  end

  def destroy
    proof = DIDWW::Resource::Proof.load(id: params[:id])
    if proof.destroy
      flash[:success] = 'Proof was successfully deleted.'
      redirect_back fallback_location: root_path
    else
      flash[:danger] = 'Failed to delete Proof: ' + proof.errors[:base].join('. ')
      redirect_back fallback_location: root_path
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:proof).permit(:proof_type_id, :entity_id, :encryption_fingerprint, :entity_type, files: [])
  end

  def apply_sorting(collection)
    collection
  end

  def default_sorting_direction
    :asc
  end
end
