class DidsController < DashboardController
  before_action :assign_params, only: [:update]

  def update
    if resource.save
      flash[:success] = 'Did was successfully updated.'
      redirect_to did_path(resource)
    else
      render :edit
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :dids,
      includes: %w(
        trunk trunk_group trunk.trunk_group
        did_group did_group.country
      ),
      allowed_filters: %w(
        country.id
        region.id
        city.id
        terminated
        awaiting_registration
        pending_removal
        number
        description
        order.reference
        trunk.id
        trunk_group.id
        did_group.id
        order.id
      )
    })
  end

  def default_sorting_column
    :number
  end

  def default_sorting_direction
    :asc
  end

  def assign_params
    resource.attributes = did_params
    assign_trunk_or_trunk_group
  end

  # A trunk can either be assigned to trunk, or trunk group
  def assign_trunk_or_trunk_group
    rel = resource.relationships
    if trunk_id.present?
      rel.trunk_group = nil
      rel.trunk = DIDWW::Resource::Trunk.load(id: trunk_id)
    elsif trunk_group_id.present?
      rel.trunk = nil
      rel.trunk_group = DIDWW::Resource::TrunkGroup.load(id: trunk_group_id)
    else
      rel.trunk = nil
      rel.trunk_group = nil
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:did).permit(
      :description,
      :capacity_limit,
      :blocked,
      :awaiting_registration,
      :terminated,
      :pending_removal,
      :trunk_id,
      :trunk_group_id
    )
  end

  def did_params
    attributes_for_save.except(:trunk_id, :trunk_group_id)
  end

  def trunk_id
    attributes_for_save[:trunk_id]
  end

  def trunk_group_id
    attributes_for_save[:trunk_group_id]
  end
end
