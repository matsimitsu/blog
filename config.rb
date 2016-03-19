require 'redcarpet'
require 'geocoder'

Geocoder.configure(:lookup => :google)

TRAVELS       = ['Asia 2016', 'Japan 2015','Asia 2015', 'USA 2014', 'Asia 2014', 'USA 2012', 'USA 2011']
BASE_URL      = 'http://matsimitsu.com'
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

###
# Compass
###

# Susy grids in Compass
# First: gem install compass-susy-plugin
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Haml
###

# CodeRay syntax highlighting in Haml
# First: gem install haml-coderay
# require 'haml-coderay'

# CoffeeScript filters in Haml
# First: gem install coffee-filter
# require 'coffee-filter'

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

###
# Page command
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

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
