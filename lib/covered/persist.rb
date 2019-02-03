# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'wrapper'

require 'msgpack'

module Covered
	class Persist < Wrapper
		def initialize(output, path = ".covered")
			super(output)
			
			@path = path
		end
		
		def apply(record)
			path = expand_path(record[:path])
			
			record[:coverage].each_with_index do |count, index|
				self.mark(path, index, count) if count
			end
		end
		
		def serialize(coverage)
			{
				# We want to use relative paths so that moving the repo won't break everything:
				path: relative_path(coverage.path),
				coverage: coverage.counts,
			}
		end
		
		def load!(path = @path)
			return unless File.exist?(@path)
			
			# Load existing coverage information and mark all files:
			File.open(@path, "r") do |file|
				make_unpacker(file).each(&self.method(:apply))
			end
		end
		
		def save!(path = @path)
			# Dump all coverage:
			File.open(@path, "w") do |file|
				packer = make_packer(file)
				
				self.each do |coverage|
					packer.write(serialize(coverage))
				end
				
				packer.flush
			end
		end
		
		def enable
			super
			
			load!
		end
		
		def disable
			super
			
			save!
		end
		
		def make_packer(io)
			packer = MessagePack::Packer.new(io)
			packer.register_type(0x00, Symbol, :to_msgpack_ext)
			
			return packer
		end
		
		def make_unpacker(io)
			unpacker = MessagePack::Unpacker.new(io)
			unpacker.register_type(0x00, Symbol, :from_msgpack_ext)
			
			return unpacker
		end
	end
end
