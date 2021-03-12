# frozen_string_literal: true
module RelationshipsHelper
  def selected_trunk_id
    selected_relationship_id :trunk
  end

  def selected_trunk_group_id
    selected_relationship_id :trunk_group
  end

  def selected_pop_id
    selected_relationship_id :pop
  end

  def selected_capacity_pool_id
    selected_relationship_id :capacity_pool
  end

  def selected_trunk_ids
    selected_relationship_ids :trunks
  end

  def selected_did_ids
    selected_relationship_ids :dids
  end

  private

  def selected_relationship_id(relationship)
    resource.relationships[relationship]&.dig(:data, :id)
  end

  def selected_relationship_ids(relationship)
    rel_data = resource.relationships[relationship].try(:[], :data) || []
    rel_data.map { |obj| obj[:id] }
  end
end
