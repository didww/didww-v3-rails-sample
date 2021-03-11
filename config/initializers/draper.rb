class Draper::QueryMethods::LoadStrategy::JsonApi
  METHODS = [:find, :to_a].freeze

  def allowed?(method)
    METHODS.include?(method.to_sym)
  end
end

Draper.default_query_methods_strategy = :json_api
