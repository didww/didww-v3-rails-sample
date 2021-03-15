# frozen_string_literal: true
class PermanentSupportingDocumentsController < DashboardController

  def create
    form = PermanentSupportingDocumentForm.new(resource_params)
    if form.save
      flash[:success] = 'Permanent supporting document was successfully created.'
      render status: 201, js: 'location.reload(true)'
    else
      render status: 422, json: { errors: form.errors.messages }
    end
  end

  def destroy
    permanent_document = DIDWW::Resource::PermanentSupportingDocument.load(id: params[:id])
    if permanent_document.destroy
      flash[:success] = 'Permanent supporting document was successfully deleted.'
      redirect_back fallback_location: root_path
    else
      flash[:danger] = 'Failed to delete Permanent supporting document: ' + permanent_document.errors[:base].join('. ')
      redirect_back fallback_location: root_path
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :permanent_supporting_document,
      includes: [
        :files,
        :template,
        :identity
      ]
    })
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:permanent_supporting_document).permit(:template_id, :identity_id, :encryption_fingerprint, files: [])
  end

  def apply_sorting(collection)
    collection
  end

  def default_sorting_direction
    :asc
  end
end
