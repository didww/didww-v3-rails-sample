class RequirementsController < DashboardController

  def initialize_api_config
    super.merge({
      resource_type: :requirements
    })
  end
end
