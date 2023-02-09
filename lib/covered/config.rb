# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require_relative 'policy'

module Covered
	class Config
		PATH = "config/covered.rb"
		
		def self.root
			ENV['COVERED_ROOT'] || Dir.pwd
		end
		
		def self.path(root)
			path = ::File.expand_path(PATH, root)
			
			if ::File.exist?(path)
				return path
			end
		end
		
		def self.coverage
			ENV['COVERAGE']
		end
		
		def self.load(root: self.root, coverage: self.coverage)
			derived = Class.new(self)
			
			if path = self.path(root)
				config = Module.new
				config.module_eval(::File.read(path), path)
				derived.prepend(config)
			end
			
			return derived.new(root, coverage)
		end
		
		def initialize(root, coverage)
			@root = root
			@coverage = coverage
			@policy = nil
		end
		
		def report?
			!!@coverage
		end
		
		alias :record? :report?
		
		attr :coverage
		
		def policy
			@policy ||= Policy.new.tap{|policy| make_policy(policy)}.freeze
		end
		
		def output
			policy.output
		end
		
		def start
			policy.start
		end
		
		def finish
			policy.finish
		end
		
		def call(output)
			policy.call(output)
		end
		
		def each(&block)
			policy.each(&block)
		end
		
		# Override this method to implement your own policy.
		def make_policy(policy)
			# Only files in the root would be tracked:
			policy.root(@root)
			
			# We will ignore any files in the test or spec directory:
			policy.skip(/^.*\/(test|fixtures|spec|vendor|config)\//)
			
			# We will include all files under lib, even if they aren't loaded:
			policy.include("lib/**/*.rb")
			
			policy.persist!
			
			policy.reports!(@coverage)
		end
		
		REQUIRE_COVERED_AUTOSTART = '-rcovered/autostart'
		
		def autostart!
			unless ENV['RUBYOPT'].include?(REQUIRE_COVERED_AUTOSTART)
				ENV['RUBYOPT'] = [REQUIRE_COVERED_AUTOSTART, ENV['RUBYOPT']].compact.join(' ')
			end
			
			unless ENV['COVERED_ROOT']
				ENV['COVERED_ROOT'] = @root
			end
			
			# Don't report coverage in child processes:
			ENV.delete('COVERAGE')
		end
	end
end
