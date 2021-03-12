class AddressVerificationForm < ApplicationForm
  delegate :id, to: :model

  attribute :address_id
  attribute :did_ids
  attribute :service_description
  attribute :encryption_fingerprint
  attribute :onetime_files

  validates :address_id, :did_ids, presence: true

  private

  def model
    @model ||= DIDWW::Resource::AddressVerification.new
  end

  def upload_files
    return [] unless onetime_files.present?

    DIDWW::Resource::EncryptedFile.upload(onetime_files, encryption_fingerprint)
  rescue StandardError => e
    logger.error { "#{e.class} #{e.message}\n#{e.backtrace.join("\n")}" }
    errors.add(:base, e.message)
  end

  def _save
    file_ids = upload_files
    return false if errors.any?

    dids = did_ids.map { |id| DIDWW::Resource::Did.load(id: id) }
    address = DIDWW::Resource::Address.load(id: address_id)
    uploaded_files = file_ids.map { |id| DIDWW::Resource::EncryptedFile.load(id: id) }

    model.attributes = { service_description: service_description.presence }
    model.relationships.address = address
    model.relationships.dids = dids
    model.relationships.onetime_files = uploaded_files

    if model.save
      true
    else
      propagate_errors(model)
      false
    end
  rescue StandardError => e
    logger.error { "#{e.class} #{e.message}\n#{e.backtrace.join("\n")}" }
    errors.add(:base, e.message)
    false
  end
end
