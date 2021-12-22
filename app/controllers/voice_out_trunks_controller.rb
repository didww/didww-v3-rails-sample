# frozen_string_literal: true

class VoiceOutTrunksController < DashboardController

  # cache selectable_dids before update
  before_action :selectable_dids, :assign_params, only: [:create, :update]

  helper_method :selectable_dids

  def create
    if resource.save
      flash[:success] = '"Voice Out" Trunk was successfully created.'
      redirect_to voice_out_trunk_path(resource)
    else
      render :new
    end
  end

  def update
    if resource.save
      flash[:success] = '"Voice Out" Trunk was successfully updated.'
      redirect_to voice_out_trunk_path(resource)
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = '"Voice Out" Trunk was successfully deleted.'
      redirect_to voice_out_trunks_path
    else
      flash[:danger] = 'Failed to delete "Voice Out" Trunk: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: voice_out_trunk_path(resource)
    end
  end

  def regenerate_credentials
    if resource.regenerate_credentials
      flash[:success] = 'Credentials was successfully regenerated.'
      redirect_to voice_out_trunk_path(resource)
    else
      flash[:danger] = 'Failed to regenerate credentials: ' + resource.errors[:base].join('. ')
      redirect_back fallback_location: voice_out_trunk_path(resource)
    end
  end

  private

  def initialize_api_config
    super.merge({
      resource_type: :voice_out_trunk,
      decorator_class: VoiceOutTrunkDecorator,
      includes: [:dids],
      allowed_filters: [
        :name,
        :status,
        :on_cli_mismatch_action,
        :name_contains,
        :allow_any_did_as_cli,
        :default_dst_action,
        :media_encryption_mode
      ]
    })
  end

  def default_sorting_column
    :name
  end

  def default_sorting_direction
    :asc
  end

  def assign_params
    resource.attributes = voice_out_trunk_params
    assign_dst_prefixes
    assign_allowed_sip_ips
    assign_allowed_rtp_ips
    assign_dids
  end

  def assign_dids
    return if resource.allow_any_did_as_cli

    dids = Array.wrap(attributes_for_save[:did_ids]).map do |id|
      DIDWW::Resource::Did.load(id: id) if id.present?
    end
    resource.relationships.dids = dids.compact
  end

  def assign_dst_prefixes
    dst_prefixes = attributes_for_save[:dst_prefixes]&.split(' ') || []
    resource.model.dst_prefixes = dst_prefixes
  end

  def assign_allowed_sip_ips
    allowed_sip_ips = attributes_for_save[:allowed_sip_ips]&.reject(&:blank?)
    resource.model.allowed_sip_ips = allowed_sip_ips
  end

  def assign_allowed_rtp_ips
    allowed_rtp_ips = attributes_for_save[:allowed_rtp_ips]&.reject(&:blank?)
    resource.model.allowed_rtp_ips = allowed_rtp_ips
  end

  def voice_out_trunk_params
    attributes_for_save.except(:did_ids, :allowed_rtp_ips, :allowed_sip_ips, :dst_prefixes)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:voice_out_trunk).permit(
      :name,
      :on_cli_mismatch_action,
      :capacity_limit,
      :allow_any_did_as_cli,
      :status,
      :threshold_amount,
      :default_dst_action,
      :dst_prefixes,
      :media_encryption_mode,
      :callback_url,
      :force_symmetric_rtp,
      :rtp_ping,
      :voice_in_trunk,
      allowed_sip_ips: [],
      allowed_rtp_ips: [],
      did_ids: []
    )
  end

  def selectable_dids
    @selectable_dids ||= DIDWW::Resource::Did.where('did_group.features': 'voice_out').includes(:'did_group.country').all
  end

end
