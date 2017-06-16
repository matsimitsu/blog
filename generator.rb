#encoding: utf-8

require 'commander/import'
require 'geocoder'
require 'yaml'
require 'fileutils'
require 'fastimage'
require 'middleman-blog'
require 'nokogiri'
require 'restclient'
require 'json'
require 'yaml'

VALID_IMAGES = %w( png jpg )
Encoding.default_external = Encoding::UTF_8
Geocoder.configure(:lookup => :google, :timeout => (1 * 60))

@config = YAML.load_file('data/config.yml')

# :name is optional, otherwise uses the basename of this executable
program :name,        'Matsimitsu'
program :version,     '1.0.0'
program :description, 'Generator for my travel blogposts.'

command :post do |c|
  c.syntax      = 'generator post [options]'
  c.description = 'Generate a new post'
  c.option '--photos STRING', String, 'Path to photos'
  c.option '--trip STRING', String, 'Trip slug'

  c.action do |args, options|
    prefix     = @config['trip_prefix']
    trips_path = File.join(Dir.pwd, 'source', prefix)
    hotel      = nil

    # Get trip from option or ask for it
    unless trip = options.trip
      prefix     = @config['trip_prefix']
      trips      = Dir
        .glob(File.join(trips_path, '*'))
        .select {|f| File.directory? f}
        .map { |f| File.basename f}

      # Get blog, title and date
      trip = choose("Select trip", *trips)
    end

    # Get the title and generate a slug for it
    title      = ask "Post title: "

    # Create variables for the destination folder and file
    title_slug = title.downcase.gsub(' ', '-')
    dest_dir   = File.join(trips_path, trip, title_slug)
    dest_file  = File.join(dest_dir, 'index.html.haml')

    # Make sure we want to overwrite the file
    if File.exists?(dest_file)
      next unless agree("File already exists, overwrite?: ")
    end

    # Get the date for the post, default to today
    date = ask("Date: ", Date) { |q| q.default = Date.today.to_s }

    # Ask for, and geolocate locations
    locations = []
    continue  = true
    loop do

      location = ask "Location address: "
      break unless location
      say "Geocoding: #{location}..."
      results = Geocoder.search(location)

      # Show the results and let the user decide for the best match
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

    # Add hotel info, if wanted
    hotel_url = ask("(Booking) hotel url: ")
    if hotel_url.to_s.length > 0
      begin
        page = Nokogiri::HTML(RestClient.get(hotel_url))
        json = JSON.parse(page.xpath('//script[@type="application/ld+json"]')[0])
        hotel = {
          'name'        => json['name'],
          'address'     => json['address']['streetAddress'],
          'image'       => json['image'],
          'priceRange'  => json['priceRange'],
          'url'         => json['url'] + "?aid=939121",
          'map'         => json['hasMap'],
          'description' => json['description'],
          'rating'      => json['aggregateRating']['ratingValue']
        }
      rescue => e
        puts "Hotel could not be parsed : #{e.inspect}"
      end
    end

    # Check for photos
    if options.photos
      photos = []

      base_path = File.expand_path(options.photos)

      # Get all images from the specified directory
      # and create photo strings from them
      Dir.foreach(base_path) do |item|
        extension = item.downcase.split('.').last
        next unless VALID_IMAGES.include?(extension)

        path            = File.join(base_path, item)
        width, height   = FastImage.size(path)
        cdn_path        = "#{trip}/#{title_slug}/#{item}"

        photos << "= photo(:src => cdn_url('#{cdn_path}'), :ratio => #{(width.to_f/height.to_f).round(3)})"
      end
    else
      photos = []
    end

    # Generate article header YAML
    yaml = {
      'title'     => title,
      'date'      => date,
      'locations' => locations,
    }
    yaml['hotel'] = hotel if hotel

    # Generate the post template
    template = %Q(#{yaml.to_yaml}
---

#{photos.join("\n")}
)
    FileUtils.mkdir_p(dest_dir)
    File.write(dest_file, template)

    say "Post generated: #{dest_file}"

    next unless options.photos
    next unless agree("Upload photos to cdn?: ")

    base_path        = File.expand_path(options.photos)
    valid_files      = []
    remote_base_path = "#{@config['ssh_dir']}/cdn/#{trip}/#{title_slug}"

    Dir.foreach(base_path) do |item|
      extension = item.downcase.split('.').last
      next unless VALID_IMAGES.include?(extension)
      valid_files << item
    end

    say "Uploading #{valid_files.length} photos to #{@config['ssh_host']}"
    %x(ssh #{@config['ssh_user']}@#{@config['ssh_host']} 'mkdir -p #{remote_base_path}')

    progress valid_files do |item|
      local_path = File.join(base_path, item)
      remote_path = "#{remote_base_path}/#{item}"
      %x(scp #{local_path} #{@config['ssh_user']}@#{@config['ssh_host']}:#{remote_path})
    end
  end
end
