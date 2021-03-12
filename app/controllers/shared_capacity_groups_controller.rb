# frozen_string_literal: true
class SharedCapacityGroupsController < DashboardController
  # cache selectable_dids before update
  before_action :selectable_dids, :assign_params, only: [:create, :update]

  helper_method :selectable_dids

  def create
    if resource.save
      flash[:success] = 'Shared Capacity Group was successfully created.'
      redirect_to shared_capacity_group_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = 'Shared Capacity Group was successfully updated.'
      redirect_to shared_capacity_group_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Shared Capacity Group was successfully deleted.'
      redirect_to shared_capacity_groups_path
    else
      flash[:danger] = 'Failed to delete Shared Capacity Group: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: shared_capacity_group_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :shared_capacity_groups,
      includes: [:capacity_pool, :'capacity_pool.countries', :dids, :'dids.did_group', :'dids.did_group.country'],
    })
  end

  def default_sorting_column
    :name
  end

  def default_sorting_direction
    :asc
  end

  def assign_params
    resource.attributes = shared_capacity_group_params
    assign_dids
    assign_capacity_pool
  end

  def assign_dids
    dids = Array.wrap(did_ids).map do |id|
      DIDWW::Resource::Did.load(id: id) if id.present?
    end
    resource.relationships.dids = dids.compact
  end

  def assign_capacity_pool
    return unless resource.new_record?
    resource.relationships.capacity_pool = DIDWW::Resource::CapacityPool.load(id: capacity_pool_id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:shared_capacity_group).permit(
      :name,
      :shared_channels_count,
      :metered_channels_count,
      :capacity_pool_id,
      did_ids: []
    )
  end

  def shared_capacity_group_params
    attributes_for_save.except(:capacity_pool_id, :did_ids)
  end

  def capacity_pool_id
    attributes_for_save[:capacity_pool_id]
  end

  def did_ids
    attributes_for_save[:did_ids]
  end

  def selectable_dids
    # DIDs that match countries with current shared capacity group's capacity pool
    @selectable_dids ||= begin
      dids = DIDWW::Resource::Did.includes(:'did_group.country').all
      if resource.capacity_pool
        shared_capacity_group_country_ids = resource.capacity_pool.countries.map(&:id)
        dids.select { |d| shared_capacity_group_country_ids.include?(d.did_group.country&.id) }
      else
        dids
      end
    end
  end

end
