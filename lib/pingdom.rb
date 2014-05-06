require 'httparty'

module Pingdom
	# get list of probes
	def self.probes()
		config = YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")
		pingdom = config['pingdom']
		auth = {:username => pingdom['user'], :password => pingdom['pass'] }
		#response = HTTParty.get("https://api.pingdom.com/api/2.0/probes", :basic_auth => auth, :headers => {"App-Key" => pingdom['key']}, :debug_output => $stdout)
		response = HTTParty.get("https://api.pingdom.com/api/2.0/probes", :basic_auth => auth, :headers => {"App-Key" => pingdom['key']})
		return JSON.parse(response.body).to_h
	end	
	
	# Return a list of raw test results for a specified check
	# WARNING: keep to-from to 12 hour chunks, else you'll get partial results, b/c pingdom API limits to 1000
	# checkid   INT
	# from      INT unix timestamp
	# to        INT unix timestamp
	def self.results(from, to)
		config = YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")
		pingdom = config['pingdom']
		auth = {:username => pingdom['user'], :password => pingdom['pass'] }
		#response = HTTParty.get("https://api.pingdom.com/api/2.0/results/#{pingdom['checkid'].to_i}?from=#{from.to_i}&to=#{to.to_i}", :basic_auth => auth, :headers => {"App-Key" => pingdom['key']}, :debug_output => $stdout)
		response = HTTParty.get("https://api.pingdom.com/api/2.0/results/#{pingdom['checkid'].to_i}?from=#{from.to_i}&to=#{to.to_i}", :basic_auth => auth, :headers => {"App-Key" => pingdom['key']})
		return JSON.parse(response.body).to_h
	end

end

