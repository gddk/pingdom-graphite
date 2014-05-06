#!/usr/bin/env ruby

require "#{File.expand_path(File.dirname(__FILE__))}/lib/pingdom.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/lib/graphite.rb"

# FIRST GET THE LIST OF PROBES - WILL NEED THEM LATER
@probes = {}
temp = Pingdom.probes()
temp['probes'].each do |probe|
	@probes[probe['id']] = probe
end

@halfdays = 2
@downTo = 1

@halfdays.downto(@downTo).each do |halfday|
	from = Time.now - 43200 * halfday
	to = from + 43200
	results = Pingdom.results(from, to)
	puts "From #{from.strftime("%Y-%m-%d %H:%M:%S")} to #{to.strftime("%Y-%m-%d %H:%M:%S")}"
	puts results
	puts "-----"
end

