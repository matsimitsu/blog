require 'commander/import'
require 'geocoder'
require 'yaml'
require 'fileutils'
require 'fastimage'

VALID_IMAGES = %w( png jpg )
SSH_USER     = 'matsimitsu'
SSH_HOST     = 'static1.matsimitsu.com'
SSH_DIR      = '/home/matsimitsu'

require_relative 'config' rescue nil

Geocoder.configure(:lookup => :google, :timeout => (1 * 60))

# :name is optional, otherwise uses the basename of this executable
program :name,        'Matsimitsu'
program :version,     '1.0.0'
program :description, 'Generator for my travel blogposts.'

command :post do |c|
  c.syntax = 'generator post [options]'
  c.description = 'Generate a new post'
  c.option '--photos STRING', String, 'Path to photos'
  c.action do |args, options|
    # Get blog, title and date
    blog       = choose("Select trip", *TRAVELS)
    blog_slug  = blog.downcase.gsub(' ', '')

    title      = ask "Post title: "
    title_slug = title.downcase.gsub(' ', '-')

    dest_dir   = File.join(Dir.pwd, 'source', 'travel', blog_slug, title_slug)
    dest_file  = File.join(dest_dir, 'index.html.haml')

    if File.exists?(dest_file)
      return unless agree("File already exists, overwrite?: ")
    end

    date = ask("Date: ", Date) { |q| q.default = Date.today.to_s }

    # Ask for, and geolocate locations
    locations = []
    continue  = true
    loop do
      location = ask "Location address: "
      break unless location
      say "Geocoding: #{location}..."
      results = Geocoder.search(location)

      if results.any?
        address     = choose("Select location", *results.map(&:formatted_address))
        coordinates = results.find { |r| r.formatted_address == address }.coordinates

        location_title = ask("Location title: ") { |q| q.default = location }
        locations << {
          'title' => location_title,
          'latlng' => coordinates
        }
      else
        say "Address not found, please try again"
      end
      break unless agree("Add another location?: ")
    end

    # Check for photos
    if options.photos
      say "Processing photos"
      photos = []

      base_path = File.expand_path(options.photos)

      Dir.foreach(base_path) do |item|
        extension = item.downcase.split('.').last
        next unless VALID_IMAGES.include?(extension)

        path            = File.join(base_path, item)
        width, height   = FastImage.size(path)
        cdn_path        = "#{blog_slug}/#{title_slug}/#{item}"

        photos << "=photo(:src => cdn_url('#{cdn_path}'), :ratio => #{(width/height).round(3)}')"
      end
    end

    # Generate article header YAML
    yaml = {
      'title'     => title,
      'date'      => date,
      'locations' => locations
    }.to_yaml

    say "Generating post: #{dest_file}"

    template = %Q(#{yaml}
---

#{photos.join("\n")}
)
    FileUtils.mkdir_p(dest_dir)
    File.write(dest_file, template)

    return unless options.photos
    return unless agree("Upload photos to cdn?: ")

    base_path        = File.expand_path(options.photos)
    valid_files      = []
    remote_base_path = "#{SSH_DIR}/cdn/#{blog_slug}/#{title_slug}"

    Dir.foreach(base_path) do |item|
      extension = item.downcase.split('.').last
      next unless VALID_IMAGES.include?(extension)
      valid_files << item
    end

    say "Uploading #{valid_files.length} photos to #{SSH_HOST}"
    %x(ssh #{SSH_USER}@#{SSH_HOST} 'mkdir -p #{remote_base_path}')

    progress valid_files do |item|
      local_path = File.join(base_path, item)
      remote_path = "#{remote_base_path}/#{item}"
      %x(scp #{local_path} #{SSH_USER}@#{SSH_HOST}:#{remote_path})
    end
  end
end
