class DashboardController < ApplicationController
  include ApiNestedResources
  include AttributesForSave

  layout 'dashboard'

  before_action :ensure_logged_in

  helper_method :countries, :did_group_types, :trunks, :trunk_groups, :pops

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

  def ensure_logged_in
    if !logged_in?
      session[:redirect_to] = request.url
      redirect_to :login
    end
  end
end
