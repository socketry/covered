# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require "covered/files"
require "covered/summary"
require "covered/capture"

require "xrb/template"

let(:template_path) {File.expand_path("template.xrb", __dir__)}
let(:template) {XRB::Template.load_file(template_path)}

let(:files) {Covered::Files.new}
let(:only) {Covered::Only.new(template_path, files)}
let(:capture) {Covered::Capture.new(files)}

let(:summary) {Covered::Summary.new}

it "correctly generates coverage for template" do
	skip "Unsupported Ruby Version" unless RUBY_VERSION >= "3.2"
	
	capture.start
	template.to_string
	capture.finish
	
	expect(files.paths).to be(:include?, template_path)
	
	io = StringIO.new
	summary.call(files, io)
	
	# Show the actual coverage:
	# Covered::Summary.new(threshold: nil).call(files, $stderr)
	
	expect(io.string).to be(:include?, "2/3 lines executed; 66.67% covered")
end
