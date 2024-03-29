# frozen_string_literal: true
class VoiceInTrunkGroupsController < DashboardController
  before_action :assign_params, only: [:create, :update]

  def create
    if resource.save
      flash[:success] = '"Voice In" Trunk Group was successfully created.'
      redirect_to voice_in_trunk_group_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = '"Voice In" Trunk Group was successfully updated.'
      redirect_to voice_in_trunk_group_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = '"Voice In" Trunk Group was successfully deleted.'
      redirect_to voice_in_trunk_groups_path
    else
      flash[:danger] = 'Failed to delete "Voice In" Trunk Group: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: voice_in_trunk_group_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :voice_in_trunk_groups,
      includes: [:voice_in_trunks],
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
    voice_in_trunks = Array.wrap(attributes_for_save[:voice_in_trunk_ids]).map do |id|
      DIDWW::Resource::VoiceInTrunk.load(id: id) if id.present?
    end
    resource.relationships.voice_in_trunks = voice_in_trunks.compact
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:voice_in_trunk_group).permit(
      :name,
      :capacity_limit,
      voice_in_trunk_ids: []
    )
  end

  def trunk_group_params
    attributes_for_save.except(:voice_in_trunk_ids)
  end
end
