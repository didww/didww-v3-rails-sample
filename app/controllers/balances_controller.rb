# frozen_string_literal: true
class BalancesController < DashboardController
  def show
    reload_user_balance
  end
end
