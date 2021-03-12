module EntitiesHelper
  def entity_name(entity)
    entity.company_name || full_name(entity)
  end

  def available_proof_types
    proof_types_for_current_entity - presented_proof_types
  end

  private

  def presented_proof_types
    resource.proofs.map(&:proof_type).map { |p| [ p.name, p.id ] }
  end

  def proof_types_for_current_entity
    entity_type = resource.type == 'identities' ? resource.identity_type : 'Address'
    DIDWW::Resource::ProofType.where(entity_type: entity_type).map { |p| [ p.name, p.id ] }
  end
end
