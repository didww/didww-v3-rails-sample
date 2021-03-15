# frozen_string_literal: true
class ProofForm < ApplicationForm
  attribute :entity_id
  attribute :proof_type_id
  attribute :encryption_fingerprint
  attribute :files
  attribute :entity_type

  validates :files, :entity_id, :proof_type_id, presence: true
  validates_with EntityTypeValidator

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
    entity = "DIDWW::Resource::#{self.entity_type}".constantize.load(id: self.entity_id)
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
