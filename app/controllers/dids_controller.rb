# frozen_string_literal: true
class DidsController < DashboardController
  include WithBatchActions

  # cache selectable pools before update
  before_action :assign_params, :capacity_pools_for_did, only: [:update]

  helper_method :capacity_pools_for_did

  def update
    if resource.save
      flash[:success] = 'Did was successfully updated.'
      redirect_to did_path(resource)
    else
      render :edit
    end
  end

  batch_action :create_verification do
    data = params.require(:batch_action).permit(
      :address_id,
      :service_description,
      :encryption_fingerprint,
      :onetime_files,
      onetime_files: []
    )

    form = AddressVerificationForm.new(data)
    form.did_ids = params[:record_ids]

    if form.save
      flash[:success] = 'Address Verification was successfully created.'
      render js: "window.location = '#{address_verification_path(form.id)}'"
    else
      render status: 422, json: { errors: form.errors.messages }
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :dids,
      decorator_class: DidDecorator,
      includes: %w(
        voice_in_trunk
        voice_in_trunk_group
        voice_in_trunk.voice_in_trunk_group
        did_group.requirement
        did_group.country
      ),
      allowed_filters: %w(
        country.id
        region.id
        city.id
        terminated
        awaiting_registration
        billing_cycles_count
        number
        description
        order.reference
        voice_in_trunk.id
        voice_in_trunk_group.id
        did_group.id
        order.id
        nanpa_prefix.id
      )
    })
  end

  def default_sorting_column
    :created_at
  end

  def default_sorting_direction
    :desc
  end

  def assign_params
    resource.attributes = did_params
    assign_voice_in_trunk_or_voice_in_trunk_group
    assign_capacity_pool
  end

  # A voice_in_trunk can either be assigned to voice_in_trunk, or voice_in_trunk group
  def assign_voice_in_trunk_or_voice_in_trunk_group
    rel = resource.relationships
    if voice_in_trunk_id.present?
      rel.voice_in_trunk_group = nil
      rel.voice_in_trunk = DIDWW::Resource::VoiceInTrunk.load(id: voice_in_trunk_id)
    elsif voice_in_trunk_group_id.present?
      rel.voice_in_trunk = nil
      rel.voice_in_trunk_group = DIDWW::Resource::VoiceInTrunkGroup.load(id: voice_in_trunk_group_id)
    else
      rel.voice_in_trunk = nil
      rel.voice_in_trunk_group = nil
    end
  end

  def assign_capacity_pool
    pool = DIDWW::Resource::CapacityPool.load(id: capacity_pool_id) if capacity_pool_id.present?
    resource.relationships.capacity_pool = pool
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:did).permit(
      :description,
      :capacity_limit,
      :dedicated_channels_count,
      :blocked,
      :awaiting_registration,
      :terminated,
      :billing_cycles_count,
      :voice_in_trunk_id,
      :voice_in_trunk_group_id,
      :capacity_pool_id
    )
  end

  def did_params
    attributes_for_save.except(:voice_in_trunk_id, :voice_in_trunk_group_id, :capacity_pool_id)
  end

  def voice_in_trunk_id
    attributes_for_save[:voice_in_trunk_id]
  end

  def voice_in_trunk_group_id
    attributes_for_save[:voice_in_trunk_group_id]
  end

  def capacity_pool_id
    attributes_for_save[:capacity_pool_id]
  end

  # Capacity pools that have this DID's country
  def capacity_pools_for_did
    @capacity_pools_for_did ||= begin
      capacity_pools = DIDWW::Resource::CapacityPool.includes(:countries).all
      capacity_pools.select { |cp| cp.countries.map(&:id).include? resource.did_group.country&.id }
    end
  end
end
