require 'redcarpet'

activate :blog do |blog|
  blog.prefix               = data.config.trip_prefix
  blog.name                 = 'Travel'
  blog.permalink            = "{trip_slug}/{title}"
  blog.sources              = "{trip_slug}/{title}/index.html"
  blog.new_article_template = "source/template.erb"
  blog.layout               = "trip_layout"
  blog.default_extension    = '.haml'

end

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :syntax

activate :blog do |blog|
  blog.prefix               = 'blog'
  blog.name                 = 'Blog'
  blog.permalink            = "/{year}-{month}-{day}-{title}"
  blog.sources              = "/{year}-{month}-{day}-{title}.html"
  blog.new_article_template = "source/template_blog.erb"
  blog.layout               = "blog_layout"
  blog.default_extension    = '.haml'
end

activate :blog do |blog|
  blog.prefix               = 'photoset'
  blog.name                 = 'Photosets'
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

  def page_title
    parts = []
    parts << current_page.data.title.presence
    if current_article && slug = current_article.metadata[:page]['trip_slug']
      parts << trip_by_slug(slug).title
    end
    parts << blog_controller.name if blog_controller rescue false
    parts << 'Matsimitsu'
    parts.compact.join(' | ')
  end

  def description
    if current_article && current_article.data.locations
      locations = current_article
        .data
        .locations
        .map { |l| l['title'] }
        .join(', ')
      "Visiting #{locations}"
    else
      current_page.data.description ||
      current_page.data.subtitle ||
      "Matsimitsu | #{blog_controller.name rescue 'Home'}"
    end
  end

  def trip_slug_path(trip)
    "/#{data.config.trip_prefix}/#{trip}"
  end

  def trips
    sitemap
      .resources
      .select  { |r| r.path.match(/#{data.config.trip_prefix}\/\w+\/index.html/) }
      .map     { |r| r.data }
      .sort_by { |r| articles_for_trip(r).first.date }
      .reverse
  end

  def trip_by_slug(trip_slug)
    trips.find { |t| t.slug == trip_slug }
  end

  def articles_for_trip(trip)
    blog('Travel')
      .articles
      .select { |a| a.metadata[:page]['trip_slug'] == trip.slug }
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
    params['data-locations'] = articles_for_trip(trip)
      .map { |a|
        (a.data.locations || []).map { |loc|
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
    cdn_url(article.metadata[:page]['trip_slug'], article.slug, 'header.jpg')
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
