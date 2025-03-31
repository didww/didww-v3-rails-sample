# frozen_string_literal: true
class BalancesController < DashboardController
  def show
    reload_user_balance

    respond_to do |format|
      format.html do
        render 'show'
      end

      format.json do
        render json: session[:cached_balance]
      end
    end
  end
end
