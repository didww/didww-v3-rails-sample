class EntityTypeValidator < ActiveModel::Validator
  def validate(record)
    unless %w[Identity Address].include?(record.entity_type)
      record.errors.add(:entity_type, 'is invalid, should be Identity or Address')
    end
  end
end
