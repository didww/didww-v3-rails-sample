# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end
ruby '2.7.2'
gem 'rails', '~> 5.2.4'
gem 'puma', '~> 3.12'
gem 'haml', '~> 5.0'
# gem 'didww-v3', require: 'didww' # TODO: use released gem after finish
# gem 'didww-v3', path: '../v3_sdk_ruby', require: 'didww'  # TODO remove
gem 'didww-v3', github: 'senid231/didww-v3-ruby', branch: 'add-voice-out-trunks', require: 'didww'
gem 'request_store', git: 'https://github.com/didww/request_store'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'webpacker', '~> 5.2'
gem 'draper'
gem 'sentry-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'http_logger'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
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
  gem 'factory_bot_rails', require: false
  gem 'faker', require: false
  gem 'rspec-rails', require: false
  gem 'rubocop', require: false
end
group :test do
  gem 'launchy'
end
