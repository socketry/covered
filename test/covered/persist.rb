# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "covered/coverage"
require "covered/config"
require "covered/persist"
require "sus/fixtures/temporary_directory_context"
require "wrapper_examples"
require "fileutils"

describe Covered::Persist do
	it_behaves_like WrapperExamples
	
	let(:coverage) {Covered::Coverage.for(__FILE__)}
	let(:output) {Covered::Base.new}
	let(:persist) {subject.new(output)}
	let(:record) {persist.serialize(coverage)}
	
	it "can serialize coverage" do
		expect(record[:path]).to be == __FILE__
	end
end

describe Covered::Config do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	it "loads persisted coverage using the configured policy" do
		FileUtils.mkdir_p(File.join(root, "config"))
		FileUtils.mkdir_p(File.join(root, "examples"))
		FileUtils.mkdir_p(File.join(root, "lib"))
		
		File.write(File.join(root, "config", "covered.rb"), <<~RUBY)
			def ignore_paths
				super + ["examples/"]
			end
		RUBY
		
		example_path = File.join(root, "examples", "example.rb")
		lib_path = File.join(root, "lib", "example.rb")
		
		File.write(example_path, "puts :example\n")
		File.write(lib_path, "puts :lib\n")
		
		output = Covered::Files.new
		output.add(Covered::Coverage.new(Covered::Source.new(example_path), [1]))
		output.add(Covered::Coverage.new(Covered::Source.new(lib_path), [1]))
		
		database_path = File.join(root, Covered::Persist::DEFAULT_PATH)
		Covered::Persist.new(output, database_path).save!
		
		config = subject.load(root: root, reports: false)
		policy = config.policy_for(database_path)
		
		expect(policy.to_h).to have_keys(lib_path)
		expect(policy.to_h).not.to have_keys(example_path)
	end
end
