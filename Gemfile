# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end
ruby '3.3.7'
gem 'rails', '~> 7.2.2'
gem 'puma', '>= 6.0'
gem 'haml', '~> 5.0'
gem 'didww-v3', github: 'didww/didww-v3-ruby', require: 'didww'
gem 'request_store', git: 'https://github.com/didww/request_store'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'webpacker', '~> 5.2'
gem 'draper'
gem 'sentry-rails'
gem 'rack', '>= 2.2'
gem 'capybara', '>= 3.39'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
  gem 'http_logger'
  gem 'webdrivers'
  gem 'cuprite'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bundle-audit', require: false
end
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'awesome_print'
end
group :development, :test do
  gem 'faker', require: false
  gem 'rspec-rails', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', '2.31.0', require: false
  gem 'rubocop-capybara', require: false
  gem 'webmock', require: false
  gem 'rackup'
end
group :test do
  gem 'launchy'
  gem 'rack_session_access'
end
