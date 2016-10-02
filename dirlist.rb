#!/usr/bin/env ruby

require 'fastimage'
path = ARGV[0]
valid_images = %w( png jpg )
base = path.gsub('source', '')

Dir.foreach(ARGV[0]) do |item|
  next unless valid_images.include?(item.downcase.split('.').last)
  path = "#{base}#{item}"
  width, height = FastImage.size(path)

  puts "= photo(:src => cdn_url('#{path}'), :ratio => #{(width.to_f/height.to_f).round(3)})"
end
