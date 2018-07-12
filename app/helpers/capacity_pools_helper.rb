module CapacityPoolsHelper
  def max_channels_to_remove(pool)
    [
      pool.total_channels_count - pool.assigned_channels_count,
      pool.total_channels_count - pool.minimum_limit
    ].min
  end

  def billing_period_words(pool)
    [Time.now.utc, Time.parse(pool.renew_date)].map{ |d| d.strftime("%^b %-d") }.join(' - ')
  end

  def qty_based_pricings_hash(pool)
    prices = [ [1, { nrc: pool.setup_price, mrc: pool.monthly_price }] ]
    prices += pool.qty_based_pricings.map do |qbp|
      [qbp.qty, { nrc: qbp.setup_price, mrc: qbp.monthly_price }]
    end
    prices.to_h
  end

  def prorate_quotient(pool)
    # Fraction of the billing period to be paid forward to the next renew date
    renew_date = pool.renew_date.to_date
    days_in_billing_period = (renew_date - 1.month).end_of_month.day
    days_left = (renew_date - DateTime.now.utc.to_date).to_i
    days_left.to_d / days_in_billing_period
  end

end
