# frozen_string_literal: true
class PermanentSupportingDocumentForm < ApplicationForm
  attribute :template_id
  attribute :identity_id
  attribute :encryption_fingerprint
  attribute :files

  validates :files, :identity_id, :template_id, presence: true

  private

  def model
    @model ||= DIDWW::Resource::PermanentSupportingDocument.new
  end

  def upload_files
    DIDWW::Resource::EncryptedFile.upload(files, encryption_fingerprint)
  rescue StandardError => e
    errors.add(:base, e.message)
  end

  def _save
    file_ids = upload_files
    return false if errors.any?

    template = DIDWW::Resource::SupportingDocumentTemplate.load(id: template_id)
    identity = DIDWW::Resource::Identity.load(id: identity_id)
    uploaded_files = file_ids.map { |id| DIDWW::Resource::EncryptedFile.load(id: id) }
    model.relationships.identity = identity
    model.relationships.template = template
    model.relationships.files = uploaded_files

    if model.save
      true
    else
      propagate_errors(model)
      false
    end
  end
end
