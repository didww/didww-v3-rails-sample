module IdentitiesHelper
  def identity_name(identity)
    identity.company_name || full_name(identity)
  end
end
