#!/usr/bin/env ruby

require 'work_queue'
require "#{File.expand_path(File.dirname(__FILE__))}/lib/pingdom.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/lib/graphite.rb"

@checkid = ARGV.first.to_i

if ( !@checkid || @checkid <= 0 )
	puts "USAGE: pingdoma-graphite.rv <checkid>"
	exit 1
end

# FIRST GET THE LIST OF PROBES - WILL NEED THEM LATER
@probes = {}
temp = Pingdom.probes()
temp['probes'].each do |probe|
	@probes[probe['id']] = probe
end

@halfdays = 60
@downTo = 3
@now = Time.now

@graphite = Graphite.new
# Hammer on the Pingdom API with 5 threads to get done 5x as fast
wq = WorkQueue.new 5
@halfdays.downto(@downTo).each do |halfday|
	wq.enqueue_b {
		from = @now - 43200 * halfday
		to = from + 43200 -1
		puts "From #{from.strftime("%Y-%m-%d %H:%M:%S")} to #{to.strftime("%Y-%m-%d %H:%M:%S")}"
		results = Pingdom.results(@checkid, from, to)
#puts results
		results and results["results"] and results["results"].each do |result|
			country = @probes[result['probeid']]['country'].gsub(/[^A-Za-z0-9]/, "_")
			city = @probes[result['probeid']]['city'].gsub(/[^A-Za-z0-9]/, "_")
			if result['status'] == "up"
				#puts "@graphite.report(\"pingdom.#{@checkid}.rollup.responsetime\", \"#{result['responsetime'].to_f}\", \"#{result['time'].to_i}\")"
				@graphite.report("pingdom.#{@checkid}.rollup.responsetime", "#{result['responsetime'].to_f}", "#{result['time'].to_i}")
				@graphite.report("pingdom.#{@checkid}.country.#{country}.responsetime", "#{result['responsetime'].to_f}", "#{result['time']}")
				@graphite.report("pingdom.#{@checkid}.city.#{country}.#{city}.responsetime", "#{result['responsetime'].to_f}", "#{result['time'].to_i}")
			else # if result['status'] == "down"	
				puts "#{result['status']} pingdom.#{@checkid}.city.#{country}.#{city}.downtime #{Time.at(result['time'].to_i).strftime('%Y-%m-%d %H:%M:%S')}"
				@graphite.report("pingdom.#{@checkid}.rollup.downtime", "1", "#{result['time'].to_i}")
				@graphite.report("pingdom.#{@checkid}.country.#{country}.downtime", "1", "#{result['time']}")
				@graphite.report("pingdom.#{@checkid}.city.#{country}.#{city}.downtime", "1", "#{result['time'].to_i}")
			end
		end
	}
end
wq.join
@graphite.close_socket


