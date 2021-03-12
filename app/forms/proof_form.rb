class ProofForm < ApplicationForm
  attribute :identity_id
  attribute :proof_type_id
  attribute :encryption_fingerprint
  attribute :files

  validates :files, :identity_id, :proof_type_id, presence: true

  private

  def model
    @model ||= DIDWW::Resource::Proof.new
  end

  def upload_files
    DIDWW::Resource::EncryptedFile.upload(files, encryption_fingerprint)
  rescue StandardError => e
    errors.add(:base, e.message)
  end

  def _save
    file_ids = upload_files
    return false if errors.any?

    proof_type = DIDWW::Resource::ProofType.load(id: proof_type_id)
    entity = DIDWW::Resource::Identity.load(id: identity_id)
    uploaded_files = file_ids.map { |id| DIDWW::Resource::EncryptedFile.load(id: id) }
    model.relationships.proof_type = proof_type
    model.relationships.entity = entity
    model.relationships.files = uploaded_files

    if model.save
      true
    else
      propagate_errors(model)
      false
    end
  end
end
