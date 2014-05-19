require 'spec_helper'

describe Pingdom do
	
	before :all do
		@probes = {}
		temp = Pingdom.probes()
		temp['probes'].each do |probe|
			@probes[probe['id']] = probe
		end
	end
	
	describe "#probes" do
		it "is a hash" do
			@probes.class.should eql Hash
		end
		
		it "contains more than 50 probes" do
			@probes.length.should > 50
		end
	end
	
	describe "#results" do
		it "return more than 30 results for checkid 1118385 for last hour" do
			results = Pingdom.results(1118385, Time.now-60*60, Time.now)
			results["results"].length.should > 30
		end
	end
	
end