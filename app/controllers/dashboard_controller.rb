class DashboardController < ApplicationController
  include ApiNestedResources
  include AttributesForSave

  layout 'dashboard'

  before_action :ensure_logged_in

  rescue_from ApiNestedResources::CollectionError, with: :api_collection_error

  helper_method :countries, :did_group_types, :trunks, :trunk_groups, :pops, :capacity_pools, :requirements

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

  def trunks
    @trunks ||= DIDWW::Resource::Trunk.all
  end

  def trunk_groups
    @trunk_groups ||= DIDWW::Resource::TrunkGroup.all
  end

  def pops
    @pops ||= DIDWW::Resource::Pop.all
  end

  def capacity_pools
    @capacity_pools ||= DIDWW::Resource::CapacityPool.all
  end

  def requirements
    @requirements ||= DIDWW::Resource::Requirements.all
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
