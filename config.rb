require 'redcarpet'

@trips = []

data.config.trips.each do |trip|
  trip['slug'] = trip.title.downcase.gsub(' ', '')
  trip['path'] = "#{data.config.trip_prefix}/#{trip.slug}"

  # Activate blog for trip
  blog = activate :blog do |blog|
    blog.prefix               = trip.path
    blog.name                 = trip.title
    blog.permalink            = "/{title}"
    blog.sources              = "/{title}/index.html"
    blog.new_article_template = "source/template.erb"
    blog.layout               = "trip_layout"
    blog.default_extension    = '.haml'
  end
  # Add blog to trip
  trip['blog'] = blog

  # Store trips with metadata
  @trips << trip

  # Add index for trip
  proxy "#{trip.path}/index.html", "/trip_overview.html", :locals => { :trip => trip }, :ignore => true
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
  def base_url(*paths)
    "#{data.config.base_url}/#{paths.join('/')}"
  end

  def cdn_url(*paths)
    "#{data.config.cdn_base_url}/#{paths.join('/')}"
  end

  def trips
    @trips
  end

  def trip_for_blog(blog)
    trips.find{ |t| t.name == blog.name }
  end

  def map_for_trip(trip)
    # Default params
    params = {
      'id'                => 'map',
      'class'             => 'overview',
      'data-mapbox-id'    => 'matsimitsu.f687427c',
      'data-zoom-control' => 'false'
    }

    # Add trip-specific params
    trip.overview_map.each do |key,val|
      params["data-#{key}"] = val
    end if trip.overview_map

    # Add coordinates for articles
    params['data-locations'] = trip.blog
      .data
      .articles
      .map { |a|
        a.data.locations.map { |loc|
          {
            :latlng => loc.latlng,
            :title => "[#{a.title}] #{loc.title}",
            :url => a.url
          }
        }
      }
      .flatten
      .to_json
    # Generate the HTML
    capture_haml do
      haml_tag(:div, params)
    end
  end

  def article_header_image_url(article)
    path = article.url.gsub(data.config.trip_prefix, '')
    cdn_url(path, 'header.jpg')
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

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :gzip
  activate :relative_assets
end
