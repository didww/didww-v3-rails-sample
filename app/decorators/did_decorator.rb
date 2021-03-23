# frozen_string_literal: true
class DidDecorator < ResourceDecorator
  delegate :requirement, to: :did_group
  decorates_association :address_verification, with: AddressVerificationDecorator

  def requirement_link
    return if requirement.nil?

    h.link_to 'Requirement', h.requirement_path(requirement.id)
  end

  def address_verification_link
    address_verification = model.address_verification
    return if address_verification.nil?

    h.link_to address_verification.id, h.address_verification_path(address_verification.id)
  end
end
