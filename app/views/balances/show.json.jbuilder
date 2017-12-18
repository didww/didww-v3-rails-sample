json.merge! session[:cached_balance].map { |k, v| [k, number_to_currency(v)] }.to_h
json.url balance_url(format: :json)
