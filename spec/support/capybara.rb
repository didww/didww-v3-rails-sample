# frozen_string_literal: true

#Capybara.asset_host = 'http://localhost:3000'

require 'capybara/cuprite'
require 'capybara/rspec'

Capybara.server = :puma, { Silent: true }

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    timeout: 90,
    inspector: true,
    headless: false
  )
end
Capybara.javascript_driver = :cuprite
