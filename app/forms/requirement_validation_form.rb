# frozen_string_literal: true
class RequirementValidationForm < ApplicationForm
  attribute :requirement_id
  attribute :entity_id
  attribute :entity_type

  ALLOWED_ENTITY_TYPES = %w[Identity Address].freeze

  validates :requirement_id, :entity_id, presence: true
  validates :entity_type, inclusion: { in: ALLOWED_ENTITY_TYPES,
                                       message: 'Entity type is invalid, should be Identity or Address' }

  private

  def model
    @model ||= DIDWW::Resource::RequirementValidation.new
  end

  def _save
    return false if errors.any?

    entity = "DIDWW::Resource::#{entity_type}".constantize.load(id: entity_id)
    requirement = DIDWW::Resource::Requirement.load(id: requirement_id)
    model.relationships.requirement = requirement
    model.relationships[entity_type.downcase.to_sym] = entity

    if model.save
      true
    else
      propagate_errors(model)
      false
    end
  end
end
