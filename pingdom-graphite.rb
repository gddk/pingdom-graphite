#!/usr/bin/env ruby

require 'work_queue'
require "#{File.expand_path(File.dirname(__FILE__))}/lib/pingdom.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/lib/graphite.rb"

@checkid = ARGV.first.to_i

if ( !@checkid || @checkid <= 0 )
	puts "USAGE: pingdoma-graphite.rv <checkid>"
	exit 1
end

now = Time.now.to_i
# @from is now - 2 days
@from = now - 86400 * 2
@to = now

puts "@from = #{Time.at(@from).strftime("%Y-%m-%d %H:%M:%S")}, @to=#{Time.at(@to).strftime("%Y-%m-%d %H:%M:%S")}"

# FIRST GET THE LIST OF PROBES - WILL NEED THEM LATER
puts "Pingdom.probes() start"
@probes = {}
temp = Pingdom.probes()
temp['probes'].each do |probe|
	@probes[probe['id']] = probe
end
puts "Pingdom.probes() finish"

@graphite = Graphite.new
# Hammer on the Pingdom API with 5 threads to get done 5x as fast
wq = WorkQueue.new 5
# step up in 12 hour increments due to the 1000 limit on the Pingdom API
(@from..@to).step(86400/2) do |from|
	wq.enqueue_b {
		# pTo is pFrom + 12 hours - 1 second
		pFrom = from
		pTo = pFrom + 86400/2 - 1
		puts "pFrom #{Time.at(pFrom).strftime("%Y-%m-%d %H:%M:%S")} pTo #{Time.at(pTo).strftime("%Y-%m-%d %H:%M:%S")}"
		results = Pingdom.results(@checkid, Time.at(pFrom), Time.at(pTo))
#puts results
		results and results["results"] and results["results"].each do |result|
			country = @probes[result['probeid']]['country'].gsub(/[^A-Za-z0-9]/, "_")
			city = @probes[result['probeid']]['city'].gsub(/[^A-Za-z0-9]/, "_")
			if result['status'] == "up"
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

