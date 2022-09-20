# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'covered/files'
require 'covered/source'
require 'covered/summary'
require 'covered/capture'

require 'trenni/template'

describe Covered::Source do
	let(:template_path) {File.expand_path("template.trenni", __dir__)}
	let(:template) {Trenni::Template.load_file(template_path)}
	
	let(:files) {Covered::Files.new}
	let(:only) {Covered::Only.new(template_path, files)}
	let(:source) {Covered::Source.new(files)}
	let(:capture) {Covered::Capture.new(source)}
	
	let(:summary) {Covered::Summary.new}
	
	it "correctly generates coverage for template" do
		capture.enable
		template.to_string
		capture.disable
		
		expect(files.paths).to be(:include?, template_path)

		io = StringIO.new
		summary.call(source, io)
		
		expect(io.string).to be(:include?, "2/3 lines executed; 66.67% covered")
	end
	
	it "can't parse non-existant path" do
		expect(source.parse(Covered::Coverage.source("do_not_exist.rb"))).to be == nil
	end
end
