#!/usr/bin/env ruby

require 'rubygems'
require 'geocoder'

Geocoder.configure(:lookup => :google, :timeout => (1 * 60))

Geocoder.search(ARGV[0]).each do |res|
  puts "#{res.formatted_address}: #{res.coordinates.inspect}"

end
