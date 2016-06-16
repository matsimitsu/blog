//= require simplevideo
//= require visible
//= require scrollto
//= require mapbox
//= require imgix

@check_scroll = undefined

$(window).on 'scroll', ->
  clearTimeout(@check_scroll)
  @check_scroll = setTimeout(doneScrolling, 50)

doneScrolling = ->
  @check_scroll = undefined
  $(window).trigger('scroll_done')

$(document).ready ->
  $('.video').simpleVideo()

  $(window).on 'scroll_done', ->
    $('.video').each ->
      el = $(@)
      if el.visible(true)
        el.trigger('play')
      else
        el.trigger('stop')

    $('[data-src]:not(.rendered)').each ->
      el = $(@)
      return unless el.visible(true)

      width = el.width()

      # Check if preview is true (low res photos)
      if window.location.search.indexOf('preview') > -1
        width = 200

      # Give rentina screens a resolution they can work with.
      dpr = Math.ceil(window.devicePixelRatio*10) /10;
      # Replace the image src with a response image size.
      el.attr('src', "#{el.data('src')}?w=#{width}&dpr=#{dpr}") #.replace('.jpg', "-#{width}x.jpg"))
      el.addClass('rendered')

  height = $(window).height()
  $('article.trip header.big').height("#{height}px")
  $('article.post header.big').height("#{Math.round(height * 0.6)}px")

  $('.scroller').click (e) ->
    e.preventDefault();
    $.scrollTo( $(@).attr('href'), 800 );

  window.loadMapBox();

  options = {
    updateOnResizeDown : true,
    updateOnPinchZoom : true,
    fitImgTagToContainerWidth: true,
    fitImgTagToContainerHeight: true,
  };
  imgix.onready(function() {
    imgix.fluid(options);
  });
