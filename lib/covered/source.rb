# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'wrapper'

require 'thread'
require 'parser/current'

module Covered
	# The source map, loads the source file, parses the AST to generate which lines contain executable code.
	class Source < Wrapper
		def initialize(output)
			super(output)
			
			begin
				@trace = TracePoint.new(:script_compiled) do |trace|
					instruction_sequence = trace.instruction_sequence

					# We only track source files which begin at line 1, as these represent whole files instead of monkey patches.
					if instruction_sequence.first_lineno <= 1
						# Extract the source path and source itself and save it for later:
						if path = instruction_sequence.path and script = trace.eval_script
							self.add(Coverage::Source.new(path, script, instruction_sequence.first_lineno))
						end
					end
				end
			rescue
				warn "Script coverage disabled: #{$!}"
				@trace = nil
			end
		end
		
		def enable
			super
			
			@trace&.enable
		end
		
		def disable
			@trace&.disable
			
			super
		end
		
		attr :paths
		
		EXECUTABLE = {
			send: true,
			yield: true,
			# Line trace point is not triggered for return statements.
			# return: true,
			def: true,
			if: true,
			lvasgn: true,
			ivasgn: true,
			cvasgn: true,
			gvasgn: true,
			match_pattern: true,
		}
		
		def executable?(node)
			EXECUTABLE[node.type]
		end
		
		IGNORE = {
			arg: true,
		}
		
		def ignore?(node)
			node.nil? || IGNORE[node.type]
		end
		
		IGNORE_CHILDREN = {
			hash: true,
			array: true,
		}
		
		def ignore_children?(node)
			IGNORE_CHILDREN[node.type]
		end
		
		IGNORE_METHOD = {
			freeze: true
		}
		
		def ignore_method?(name)
			IGNORE_METHOD[name]
		end
		
		def expand(node, coverage, level = 0)
			if node.is_a? Parser::AST::Node
				if ignore?(node)
					# coverage.annotate(node.location.line, "ignoring #{node.type}")
				elsif node.type == :begin
					# if last_child = node.children&.last
					# 	coverage.counts[last_child.location.line] ||= 0
					# end
					
					return expand(node.children, coverage, level + 1)
				elsif node.type == :send
					if ignore_method?(node.children[1])
						# coverage.annotate(node.location.line, "ignoring #{node.type}")
						return
					else
						# coverage.annotate(node.location.line, "accepting selector #{node.type}")
						coverage.counts[node.location.selector.line] ||= 0
					end
				elsif node.type == :resbody
					return expand(node.children[2], coverage, level + 1)
				elsif executable?(node)
					# coverage.annotate(node.location.line, "executable #{node.type}")
					coverage.counts[node.location.line] ||= 0
				end

				if ignore_children?(node)
					# coverage.annotate(node.location.line, "ignoring #{node.type} children")
				else
					expand(node.children, coverage, level + 1)
				end
			elsif node.is_a? Array
				node.each do |child|
					expand(child, coverage, level)
				end
			else
				return false
			end
		end
		
		def add(source)
			if coverage = super
				if top = self.parse(source)
					self.expand(top, coverage)
				end
			end
			
			return coverage
		end
		
		def parse(source)
			if source.code?
				Parser::CurrentRuby.parse(source.code, source.path, source.line_offset)
			elsif path = source.path and File.exist?(path)
				Parser::CurrentRuby.parse_file(path)
			else
				# warn "Couldn't parse #{path}, file doesn't exist?"
			end
		rescue
			warn "Couldn't parse #{source}: #{$!}"
		end
		
		def each(&block)
			@output.each do |coverage|
				if top = parse(coverage.source)
					self.expand(top, coverage)
				end
				
				yield coverage.freeze
			end
		end
	end
end
