# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require_relative "policy"

module Covered
	# Loads project coverage configuration and controls a configured policy.
	class Config
		PATH = "config/covered.rb"
		
		# The root directory used for coverage configuration.
		# @returns [String] The value of `COVERED_ROOT`, or the current working directory.
		def self.root
			ENV["COVERED_ROOT"] || Dir.pwd
		end
		
		# The coverage configuration path under the given root.
		# @parameter root [String] The project root.
		# @returns [String | Nil] The expanded configuration path if it exists.
		def self.path(root)
			path = ::File.expand_path(PATH, root)
			
			if ::File.exist?(path)
				return path
			end
		end
		
		# The report names requested by the environment.
		# @returns [String | Nil] The `COVERAGE` environment value.
		def self.reports
			ENV["COVERAGE"]
		end
		
		# Load the project coverage configuration for the given root.
		# @parameter root [String] The project root.
		# @parameter reports [String | Boolean | Array | Object | Nil] The report configuration.
		# @parameter persist [Boolean] Whether the configured policy should persist coverage to the default database.
		# @returns [Covered::Config] The loaded configuration instance.
		def self.load(root: self.root, reports: self.reports, persist: true)
			derived = Class.new(self)
			
			if path = self.path(root)
				config = Module.new
				config.module_eval(::File.read(path), path)
				derived.prepend(config)
			end
			
			return derived.new(root, reports, persist)
		end
		
		# Initialize the configuration for a project root and reports.
		# @parameter root [String] The project root.
		# @parameter reports [String | Boolean | Array | Object | Nil] The report configuration.
		# @parameter persist [Boolean] Whether the configured policy should persist coverage to the default database.
		def initialize(root, reports, persist = true)
			@root = root
			@reports = reports
			@policy = nil
			@persist = persist
			
			@environment = nil
		end
		
		# Whether reports should be generated.
		# @returns [Boolean] Whether reporting is enabled.
		def report?
			!!@reports
		end
		
		alias :record? :report?
		
		# @attribute [Covered::Policy | Nil] The active coverage policy, if assigned by an integration.
		attr :coverage
		
		# The configured coverage policy.
		# @returns [Covered::Policy] The memoized, frozen policy.
		def policy
			@policy ||= Policy.new.tap{|policy| make_policy(policy)}.freeze
		end
		
		# The configured policy output wrapper.
		# @returns [Covered::Base] The output wrapper at the end of the policy pipeline.
		def output
			policy.output
		end
		
		# Start coverage tracking.
		# Stores the current environment, configures child process autostart, and starts the policy capture pipeline.
		def start
			# Save and setup the environment:
			@environment = ENV.to_h
			autostart!
			
			# Start coverage tracking:
			policy.start
		end
		
		# Finish coverage tracking.
		# Stops the policy capture pipeline and restores the environment saved by {start}.
		def finish
			# Finish coverage tracking:
			policy.finish
			
			# Restore the environment:
			ENV.replace(@environment)
			@environment = nil
		end
		
		# Generate coverage reports to the given output.
		# @parameter output [IO] The output stream to write the coverage report to.
		def call(output)
			policy.call(output)
		end
		
		# Enumerate the coverage data from the configured policy.
		# @yields {|coverage| ...} Each coverage object from the policy.
		# 	@parameter coverage [Covered::Coverage] The current coverage object.
		def each(&block)
			policy.each(&block)
		end
		
		# Build a configured policy using coverage data from persistent storage.
		#
		# @parameter paths [Array(String)] The coverage database paths.
		# @parameter ignore_mtime [Boolean] Whether to ignore source file modification times.
		# @returns [Covered::Policy] The configured policy with loaded coverage data.
		def policy_for(paths = nil, ignore_mtime: true)
			paths ||= Dir.glob(Persist::DEFAULT_PATH, base: @root)
			paths = Array(paths)
			
			if paths.empty?
				raise ArgumentError, "No coverage paths specified!"
			end
			
			paths.each do |path|
				# It would be nice to have a better algorithm here than just ignoring mtime - perhaps using checksums:
				Persist.new(policy.output, path).load!(ignore_mtime: ignore_mtime)
			end
			
			return policy
		end
		
		# Which paths to ignore when computing coverage for a given project.
		# @returns [Array(String)] An array of relative paths to ignore.
		def ignore_paths
			["test/", "fixtures/", "spec/", "vendor/", "config/"]
		end
		
		# Which paths to include when computing coverage for a given project.
		# @returns [Array(String)] An array of relative patterns to include, e.g. `"lib/**/*.rb"`.
		def include_patterns
			["lib/**/*.rb"]
		end
		
		# Override this method to implement your own policy.
		# @parameter policy [Covered::Policy] The policy to configure.
		def make_policy(policy)
			# Only files in the root would be tracked:
			policy.root(@root)
			
			patterns = ignore_paths.map do |path|
				File.join(@root, path)
			end
			
			# We will ignore any files in the test or spec directory:
			policy.skip(Regexp.union(patterns))
			
			# We will include all files under lib, even if they aren't loaded:
			include_patterns.each do |pattern|
				policy.include(pattern)
			end
			
			policy.persist! if @persist
			
			policy.reports!(@reports)
		end
		
		protected
		
		REQUIRE_COVERED_AUTOSTART = "-rcovered/autostart"
		
		def autostart!
			if rubyopt = ENV["RUBYOPT"] and !rubyopt.empty?
				rubyopt = [rubyopt.strip, REQUIRE_COVERED_AUTOSTART].join(" ")
			else
				rubyopt = REQUIRE_COVERED_AUTOSTART
			end
			
			ENV["RUBYOPT"] = rubyopt
			
			ENV["COVERED_ROOT"] = @root
			
			# Don't report coverage in child processes:
			ENV.delete("COVERAGE")
		end
	end
end
