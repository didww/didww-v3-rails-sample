class ProofForm
  include ActiveModel::Model

  attr_accessor :proof_type_id, :identity_id, :encryption_fingerprint, :files

  validates :files, presence: true
  validates :proof_type_id, presence: true

  def save
    return false unless valid?

    _save
  end

  private

  def resource
    @resource ||= DIDWW::Resource::Proof.new
  end

  def _save
    proof_type = DIDWW::Resource::ProofType.load(id: self.proof_type_id)
    entity = DIDWW::Resource::Identity.load(id: self.identity_id)
    file_ids = DIDWW::Resource::EncryptedFile.upload(self.files, self.encryption_fingerprint)
    files = file_ids.map { |id| DIDWW::Resource::EncryptedFile.load(id: id) }
    resource.relationships.proof_type = proof_type
    resource.relationships.entity = entity
    resource.relationships.files = files
    resource.save
  end
end
