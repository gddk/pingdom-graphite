require 'spec_helper'

describe Graphite do
	
	before :all do
		@graphite = Graphite.new
	end
	
	describe "#new" do
		it "returns a new graphite object" do
			@graphite.should be_an_instance_of Graphite
		end
		
		it "has a host" do
			@graphite.host.should be_an_instance_of String
		end
		
		it "has a port" do
			@graphite.port.to_i.should > 0
			@graphite.port.to_i.should < 65536
		end
		
		it "has an open socket" do
			sock = @graphite.socket
			sock.should be_an_instance_of TCPSocket
			sock.closed?.should eql false
		end
	end
	
	describe "#report" do
		it "reports to graphite without socket error" do
			@graphite.report("test.rspec.value", 1.0)
			sock = @graphite.socket
			sock.should be_an_instance_of TCPSocket
			sock.closed?.should eql false
		end
	end
	
end