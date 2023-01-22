module IntegrationExamples
	def self.integration_path(name)
		File.join(__dir__, 'integration', name)
	end
	
	def self.run(name)
		input, output = IO.pipe
		
		system("ruby", "test.rb", chdir: self.integration_path(name), out: output, exception: true)
		output.close
		
		return input.read
	end
end
