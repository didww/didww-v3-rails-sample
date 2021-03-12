# frozen_string_literal: true
class DidReservationsController < DashboardController

  def create
    assign_params
    if resource.save
      formatted = FormattedDuration.parse(resource.expire_at.utc - Time.now.utc)
      render status: :created, json: { did_reservation: { id: resource.id, duration: formatted } }
    else
      render status: :unprocessable_entity, json: { error: resource.errors.full_messages.to_sentence }
    end
  end

  def destroy
    if resource.destroy
      head :no_content
    else
      msg = 'Failed to delete Reservation: ' + resource.errors[:base].to_sentence
      render status: :unprocessable_entity, json: { error: msg }
    end
  end

  private

  def assign_params
    available_did = DIDWW::Resource::AvailableDid.load(id: resource_params[:available_did_id])
    resource.relationships.available_did = available_did
    resource.description = resource_params[:description].presence
  end

  def resource_params
    params.require(:did_reservation).permit(:available_did_id, :description)
  end

  def initialize_api_config
    super.merge({
                    resource_type: :did_reservations,
                    includes: [
                        :available_did,
                        :'available_did.did_group',
                        :'available_did.did_group.stock_keeping_units',
                        :'available_did.did_group.country',
                        :'available_did.did_group.city',
                        :'available_did.did_group.region',
                        :'available_did.did_group.did_group_type'
                    ],
                    allowed_filters: %w(description)
                })
  end

  def default_sorting_column
    :created_at
  end

end
