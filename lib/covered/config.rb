# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require_relative 'policy'

module Covered
	class Config
		PATH = "config/covered.rb"
		
		def self.path(root)
			path = ::File.join(root, PATH)
			
			if ::File.exist?(path)
				return path
			end
		end
		
		def self.coverage
			ENV['COVERAGE']
		end
		
		def self.load(root: Dir.pwd, coverage: self.coverage)
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
		
		def record?
			!!@coverage
		end
		
		attr :coverage
		
		def policy
			@policy ||= Policy.new.tap{|policy| make_policy(policy)}.freeze
		end
		
		def output
			policy.output
		end
		
		def enable
			policy.enable
		end
		
		def disable
			policy.disable
		end
		
		def flush
			policy.flush
		end
		
		def call(output)
			policy.call(output)
		end
		
		def each(&block)
			policy.each(&block)
		end
		
		# Override this method to implement your own policy.
		def make_policy(policy)
			policy.cache!
			
			# Only files in the root would be tracked:
			policy.root(@root)
			
			# We will ignore any files in the test or spec directory:
			policy.skip(/^.*\/(test|spec|vendor|config)\//)
			
			# We will include all files under lib, even if they aren't loaded:
			policy.include("lib/**/*.rb")
			
			policy.persist!
			
			policy.source
			
			policy.reports!(@coverage)
		end
	end
end
