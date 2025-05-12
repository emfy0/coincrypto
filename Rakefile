# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

Rake::ExtensionTask.new("coincrypto") do |c|
  c.lib_dir = "lib/coincrypto"
end

task default: :spec
