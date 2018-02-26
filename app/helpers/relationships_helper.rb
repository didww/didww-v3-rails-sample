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

  def selected_trunk_ids
    selected_relationship_ids :trunks
  end

  private

  def selected_relationship_id(relationship)
    resource.relationships[relationship]&.dig(:data, :id)
  end

  def selected_relationship_ids(relationship)
    resource.relationships[relationship]&.fetch(:data, []).map{ |obj| obj[:id] }
  end

end
