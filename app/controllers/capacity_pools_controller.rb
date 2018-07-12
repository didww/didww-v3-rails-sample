class CapacityPoolsController < DashboardController
  before_action :assign_params, only: [:update]

  def update
    if resource.save
      flash[:success] = 'Capacity Pool was successfully updated.'
      redirect_to capacity_pool_path(resource)
    else
      flash[:danger] = resource.errors.full_messages.to_sentence
      redirect_to resource
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :capacity_pools,
      includes: [:shared_capacity_groups, :countries, :qty_based_pricings],
    })
  end

  def default_sorting_column
    :name
  end

  def default_sorting_direction
    :asc
  end

  def assign_params
    resource.attributes = capacity_pool_params
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:capacity_pool).permit(
      :channels_to_remove
    )
  end

  def capacity_pool_params
    {
      total_channels_count: resource.total_channels_count - resource_params[:channels_to_remove].to_i
    }
  end
end
