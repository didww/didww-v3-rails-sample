# frozen_string_literal: true
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  # require 'rspec/core/rake_task'
  require 'bundler/audit/task'

  # RSpec::Core::RakeTask.new(:spec)
  Bundler::Audit::Task.new
  RuboCop::RakeTask.new

  task default: ['bundle:audit', :rubocop]
end
