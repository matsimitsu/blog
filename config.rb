require 'redcarpet'
require 'geocoder'

Geocoder.configure(:lookup => :google)

TRAVELS       = ['Asia 2016', 'Japan 2015','Asia 2015', 'USA 2014', 'Asia 2014', 'USA 2012', 'USA 2011']
BASE_URL      = 'http://matsimitsu.com'
CDN_BASE_URL  = 'http://cdn.matsimits.com'

TRAVEL_PREFIX = '/travel'

TRAVELS.each do |travel|
  activate :blog do |blog|
    blog.prefix               = "#{TRAVEL_PREFIX}/#{travel.downcase.gsub(' ', '')}"
    blog.name                 = travel
    blog.permalink            = "/{title}"
    blog.sources              = "/{title}/index.html"
    blog.new_article_template = "source/template.erb"
    blog.layout               = "trip_layout"
    blog.default_extension    = '.haml'
  end
end

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :syntax

activate :blog do |blog|
  blog.prefix               = 'blog'
  blog.name                 = 'blog'
  blog.permalink            = "/{year}-{month}-{day}-{title}"
  blog.sources              = "/{year}-{month}-{day}-{title}.html"
  blog.new_article_template = "source/template_blog.erb"
  blog.layout               = "blog_layout"
  blog.default_extension    = '.haml'
end

activate :blog do |blog|
  blog.prefix               = 'photoset'
  blog.name                 = 'photoset'
  blog.permalink            = "/{title}"
  blog.sources              = "/{year}-{title}.html"
  blog.new_article_template = "source/template_blog.erb"
  blog.layout               = "photoset_layout"
  blog.default_extension    = '.haml'
end

activate :directory_indexes

helpers do
  def base_url
    BASE_URL
  end

  def trip_from_prefix(prefix)
    prefix.gsub(TRAVEL_PREFIX, '')
  end

  def travel_blogs
    TRAVELS.map do |travel|
      blog_instances.values.find do |blog|
        blog.name.to_s == travel.to_s
      end
    end
  end

  def photo(params)
    # Calculate the ratio
    ratio = params[:ratio] || (params[:width].to_f / params[:height].to_f).round(3)

    if params[:class]
      class_str = "photo-row-photo #{params[:class]}"
    else
      class_str = "photo-row-photo"
    end
    # Render a figure tag with ratio, and an image tag
    capture_haml do
      haml_tag :figure, :class => class_str, :style => "flex:#{ratio}" do
        haml_tag :img, :'data-src' => params[:src], :src => '//cdn.matsimitsu.com/loader.gif'
      end
    end
  end
end

# Change the CSS directory
# set :css_dir, "alternative_css_directory"

# Change the JS directory
# set :js_dir, "alternative_js_directory"

# Change the images directory
# set :images_dir, "alternative_image_directory"

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript
  activate :gzip
  # Enable cache buster
  # activate :cache_buster

  # Use relative URLs
  activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
