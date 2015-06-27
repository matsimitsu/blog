#!/usr/bin/env ruby

require 'fileutils'
path      = ARGV[0]
width     = ARGV[1] || 720
height    = ARGV[2] || 540

basename = File.basename(path).split('.')[0]
FileUtils.mkdir_p basename

`ffmpeg -i "#{path}" -c:v libx264 -pix_fmt yuv420p -movflags faststart -g 30 -an "#{basename}/#{basename}.mp4"`
`ffmpeg -i "#{path}"  -b 1500k -vcodec libvpx -acodec libvorbis -ab 160000 -f webm -g 30 -an "#{basename}/#{basename}.webm"`
`ffmpeg -i "#{path}" -b 1500k -vcodec libtheora -acodec libvorbis -ab 160000 -g 30 -an "#{basename}/#{basename}.ogv"`

puts %Q(
%video.video{:width => '100%', :loop => 'loop'}
  %source{:src =>'#{basename}.mp4', :type=>'video/mp4'}
  %source{:src =>'#{basename}.ogv', :type=>'video/ogg'}
  %source{:src =>'#{basename}.webm', :type=>'video/webm'}
)
