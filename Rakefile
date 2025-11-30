# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

Rake::ExtensionTask.new("coin_crypto") do |c|
  c.lib_dir = "lib/coin_crypto/bindings"
end

task default: :spec
