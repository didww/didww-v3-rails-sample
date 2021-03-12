# frozen_string_literal: true
class TrunksController < DashboardController
  class ConfigurationTypeError < StandardError
    def initialize(type)
      super("\"#{type}\" is not a valid trunk configuration type.")
    end
  end

  rescue_from ConfigurationTypeError, with: :configuration_type_error

  before_action :assign_params, only: [:create, :update]

  def new
    resource.configuration = configuration_klass.new(configuration_klass::DEFAULTS)
  end

  def create
    if resource.save
      flash[:success] = 'Trunk was successfully created.'
      redirect_to trunk_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = 'Trunk was successfully updated.'
      redirect_to trunk_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = 'Trunk was successfully deleted.'
      redirect_to trunks_path
    else
      flash[:danger] = 'Failed to delete Trunk: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: trunk_path(resource)
    end
  end

  def configuration_type_error(e)
    flash[:danger] = e.message
    redirect_to trunks_path
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :trunks,
      includes: [:trunk_group, :pop],
      allowed_filters: [
        'name',
        'configuration.type': []
      ]
    })
  end

  def default_sorting_column
    :name
  end

  def default_sorting_direction
    :asc
  end

  def configuration_type
    params[:type]
  end

  def configuration_klass
    resource_klass::CONST::CONF_TYPE_CLASSES[configuration_type] ||
      raise(ConfigurationTypeError, configuration_type)
  end

  def assign_params
    resource.attributes = trunk_params
    assign_trunk_group
    assign_pop
    assign_configuration
  end

  def assign_trunk_group
    trunk_group = DIDWW::Resource::TrunkGroup.load(id: trunk_group_id) if trunk_group_id.present?
    resource.relationships.trunk_group = trunk_group
  end

  def assign_pop
    pop = DIDWW::Resource::Pop.load(id: pop_id) if pop_id.present?
    resource.relationships.pop = pop
  end

  def assign_configuration
    configuration = configuration_klass.new(configuration_params)
    resource.configuration = configuration
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:trunk).permit(
      :priority,
      :weight,
      :capacity_limit,
      :ringing_timeout,
      :name,
      :cli_format,
      :cli_prefix,
      :description,
      :trunk_group_id,
      :pop_id,
      configuration_attributes: {}
    )
  end

  def trunk_params
    attributes_for_save.except(:trunk_group_id, :pop_id, :configuration_attributes)
  end

  def configuration_params
    attributes_for_save[:configuration_attributes]
  end

  def trunk_group_id
    attributes_for_save[:trunk_group_id]
  end

  def pop_id
    attributes_for_save[:pop_id]
  end

end
