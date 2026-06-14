# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "covered/files"
require "covered/capture"

require "tmpdir"

describe Covered::Capture do
	it "accumulates coverage for files loaded multiple times" do
		path = File.expand_path("capture-load-test.rb", Dir.tmpdir)
		File.write(path, "x = 1\n")
		
		files = Covered::Files.new
		capture = Covered::Capture.new(files)
		
		capture.start
		load path
		load path
		capture.finish
		
		expect(files[path].counts[1]).to be == 2
	ensure
		File.delete(path) if path && File.exist?(path)
	end
	
	it "ignores line zero when marking coverage" do
		files = Covered::Files.new
		
		files.mark("line-zero.rb", 0, [1, 2])
		
		expect(files["line-zero.rb"].counts[0]).to be_nil
		expect(files["line-zero.rb"].counts[1]).to be == 2
	end
	
	it "supports nested independent captures" do
		outer_path = File.expand_path("capture-outer-test.rb", Dir.tmpdir)
		inner_path = File.expand_path("capture-inner-test.rb", Dir.tmpdir)
		
		File.write(outer_path, "x = 1\n")
		File.write(inner_path, "y = 1\n")
		
		outer_files = Covered::Files.new
		outer_capture = Covered::Capture.new(outer_files)
		
		inner_files = Covered::Files.new
		inner_capture = Covered::Capture.new(inner_files)
		
		outer_capture.start
		load outer_path
		
		inner_capture.start
		load inner_path
		inner_capture.finish
		
		load outer_path
		outer_capture.finish
		
		expect(outer_files[outer_path].counts[1]).to be == 2
		expect(outer_files[inner_path].counts[1]).to be == 1
		expect(inner_files[inner_path].counts[1]).to be == 1
		expect(inner_files.paths).not.to have_keys(outer_path)
	ensure
		File.delete(outer_path) if outer_path && File.exist?(outer_path)
		File.delete(inner_path) if inner_path && File.exist?(inner_path)
	end
end
