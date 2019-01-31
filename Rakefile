require "bundler/gem_tasks"
require "rspec/core/rake_task"

# For RSpec
RSpec::Core::RakeTask.new(:spec)

# For Minitest
require 'rake/testtask'
Rake::TestTask.new(:test) do |task|
	task.pattern = "test/*_test.rb"
end

task :default => :spec