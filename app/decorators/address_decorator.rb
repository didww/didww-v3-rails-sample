class AddressDecorator < ResourceDecorator
  decorates_association :identity, with: IdentityDecorator
  delegate :country, to: :identity, prefix: true

  def display_name
    "#{model.country.name} #{model.address} #{model.postal_code}"
  end

  def identity_link
    h.link_to identity.display_name, h.identity_path(identity.id)
  end

  def created_at
    format_time model.created_at
  end
end
