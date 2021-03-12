# frozen_string_literal: true
module IdentitiesHelper
  def available_proof_types
    proof_types_for_current_identity - presented_proof_types
  end

  private

  def presented_proof_types
    resource.proofs.map(&:proof_type).map { |p| [ p.name, p.id ] }
  end

  def proof_types_for_current_identity
    DIDWW::Resource::ProofType.where(entity_type: resource.identity_type).map { |p| [ p.name, p.id ] }
  end
end
