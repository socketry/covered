# frozen_string_literal: true

# Copyright, 2022, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
		
		def self.load(root: Dir.pwd, coverage: ENV['COVERAGE'])
			return nil unless coverage
			
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
		
		def policy
			@policy ||= Policy.new.tap{|policy| make_policy(policy)}.freeze
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
