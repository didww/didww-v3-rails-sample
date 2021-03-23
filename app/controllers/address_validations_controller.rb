# frozen_string_literal: true
class AddressValidationsController < DashboardController

  def create
    form = AddressValidationForm.new(resource_params)
    if form.save
      render status: 201, json: { message: "#{resource_params[:entity_type]} is valid" }
    else
      render status: 422, json: { errors: form.errors.messages }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:address_validation).permit(:requirement_id, :entity_id, :entity_type, :address_id)
  end
end
