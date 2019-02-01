# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'async'
require 'async/rest/resource'

module Covered
	class Coveralls
		URL = "https://coveralls.io/api/v1/jobs"
		
		def initialize(token: nil, service: nil, job_id: nil)
			@token = token
		end
		
		def detect_service
			if token = ENV.fetch('COVERALLS_REPO_TOKEN', @token)
				return {"repo_token" => token}
			elsif @service && @job_id
				return {"service_name" => @service, "service_job_id" => @job_id}
			elsif job_id = ENV['TRAVIS_JOB_ID']
				return {"service_name" => "travis-ci", "service_job_id" => job_id}
			else
				warn "#{self.class} can't detect service! Please specify COVERALLS_REPO_TOKEN."
			end
			
			return nil
		end
		
		def call(wrapper, output = nil)
			if body = detect_service
				output.puts "Submitting data using #{body.inspect}..."
				
				source_files = []
				
				wrapper.each do |coverage|
					source_files << {
						name: coverage.path,
						source_digest: Digest::MD5.hexdigest(File.read(coverage.path)),
						coverage: coverage.to_a,
					}
				end
				
				body[:source_files] = source_files
				
				Async do
					resource = Async::REST::Resource.for(URL)
					
					response = client.post(body)
					
					output.puts "Got response: #{response.join}"
				end
			end
		end
	end
end
