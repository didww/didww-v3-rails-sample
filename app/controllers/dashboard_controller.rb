# frozen_string_literal: true
class DashboardController < ApplicationController
  include ApiNestedResources
  include AttributesForSave

  layout 'dashboard'

  before_action :ensure_logged_in

  rescue_from ApiNestedResources::CollectionError, with: :api_collection_error

  helper_method :countries,
                :did_group_types,
                :voice_in_trunks,
                :voice_in_trunk_groups,
                :voice_out_trunks,
                :pops,
                :capacity_pools,
                :requirements,
                :identities,
                :proofs,
                :addresses,
                :permanent_supporting_documents,
                :proof_types,
                :nanpa_prefixes

  private

  def initialize_api_config
    super.merge({
      per_page_values: [10, 25, 50, 100]
    })
  end

  def countries
    @countries ||= DIDWW::Resource::Country.all
  end

  def did_group_types
    @did_group_types ||= DIDWW::Resource::DidGroupType.all
  end

  def nanpa_prefixes
    @nanpa_prefixes ||= DIDWW::Resource::NanpaPrefix.all
  end

  def voice_in_trunks
    @voice_in_trunks ||= DIDWW::Resource::VoiceInTrunk.all
  end

  def voice_in_trunk_groups
    @voice_in_trunk_groups ||= DIDWW::Resource::VoiceInTrunkGroup.all
  end

  def voice_out_trunks
    @voice_in_trunk_groups ||= DIDWW::Resource::VoiceOutTrunk.all
  end

  def pops
    @pops ||= DIDWW::Resource::Pop.all
  end

  def capacity_pools
    @capacity_pools ||= DIDWW::Resource::CapacityPool.all
  end

  def requirements
    @requirements ||= DIDWW::Resource::Requirement.all
  end

  def identities
    @identities ||= DIDWW::Resource::Identity.all
  end

  def proofs
    @proofs ||= DIDWW::Resource::Proof.all
  end

  def addresses
    @addresses ||= DIDWW::Resource::Address.all
  end

  def permanent_supporting_documents
    @permanent_supporting_documents ||= DIDWW::Resource::PermanentSupportingDocument.all
  end

  def proof_types
    @proof_types ||= DIDWW::Resource::ProofType.all
  end

  def ensure_logged_in
    if !logged_in?
      session[:redirect_to] = request.url
      redirect_to :login
    end
  end

  def api_collection_error(e)
    flash[:danger] = e.message
    if request.path == root_path
      drop_session
    else
      redirect_back fallback_location: root_path
    end
  end
end
