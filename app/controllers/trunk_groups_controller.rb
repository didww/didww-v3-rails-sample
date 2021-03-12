# frozen_string_literal: true
class TrunkGroupsController < DashboardController
  before_action :assign_params, only: [:create, :update]

  def create
    if resource.save
      flash[:success] = 'Trunk Group was successfully created.'
      redirect_to trunk_group_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = 'Trunk Group was successfully updated.'
      redirect_to trunk_group_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Trunk Group was successfully deleted.'
      redirect_to trunk_groups_path
    else
      flash[:danger] = 'Failed to delete Trunk Group: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: trunk_group_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :trunk_groups,
      includes: [:trunks],
    })
  end

  def default_sorting_column
    :name
  end

  def default_sorting_direction
    :asc
  end

  def assign_params
    resource.attributes = trunk_group_params
    assign_trunks
  end

  def assign_trunks
    trunks = Array.wrap(trunk_ids).map do |id|
      DIDWW::Resource::Trunk.load(id: id) if id.present?
    end
    resource.relationships.trunks = trunks.compact
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:trunk_group).permit(
      :name,
      :capacity_limit,
      trunk_ids: []
    )
  end

  def trunk_group_params
    attributes_for_save.except(:trunk_ids)
  end

  def trunk_ids
    attributes_for_save[:trunk_ids]
  end
end
