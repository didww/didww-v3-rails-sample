# frozen_string_literal: true
class AddressVerificationDecorator < ResourceDecorator
  decorates_association :address, with: AddressDecorator
  delegate :country, to: :address, prefix: true
  delegate :identity, to: :address
  delegate :country, to: :identity, prefix: true

  def identity_link
    h.link_to identity.display_name, h.identity_path(identity.id)
  end

  def address_link
    h.link_to address.display_name, h.address_path(address.id)
  end

  def created_at
    format_time model.created_at
  end
end
