# frozen_string_literal: true
# Override client getters to use request-specific data
require 'didww/dynamic_credentials'
# Hard-code countries with regions
require 'didww/countries_with_regions'

# Initialize client
DIDWW::Client.configure do |config|
  config.api_version = '2021-04-19'
end

if Rails.env.development? || Rails.env.test?
  DIDWW::Resource::Base.connection do |conn|
    conn.response :logger, Rails.logger, { headers: true, bodies: true }
  end
end

# DIDWW::Client.with_api_version('2.0') do
#   DIDWW::Resource::Requirement.all
# end

# Demodulize resource names (for forms, etc)
class DIDWW::Resource::Base
  def model_name
    ActiveModel::Name.new(self.class, nil, self.class.name.demodulize)
  end
end

# To use complex object as nested model (forms)
class DIDWW::ComplexObject::Base
  def persisted?
    false
  end
end
