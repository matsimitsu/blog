//= require jquery
//= require simplevideo
//= require visible
//= require scrollto
//= require mapbox_source
//= require mapbox

@check_scroll = undefined

$(window).on 'scroll', ->
  clearTimeout(@check_scroll)
  @check_scroll = setTimeout(doneScrolling, 50)

doneScrolling = ->
  @check_scroll = undefined
  $(window).trigger('scroll_done')

preload = (src, callback) ->
  tmp = new Image()
  if (callback)
    tmp.onload = ->
      callback.call();

  tmp.src = src

$(document).ready ->
  $('[data-bg-src]:not(.rendered)').each ->
    el = $(@)
    width = el.width()

    # Check if preview is true (low res photos)
    if window.location.search.indexOf('preview') > -1
      width = 200
    # Give rentina screens a resolution they can work with.
    else if window.devicePixelRatio > 1
      width = width * 2
    # Replace the image src with a response image size.
    url = el.data('bg-src').replace('.jpg', "-#{width}x.jpg")

    preload url, ->
      el.css('background-image', "url(#{url}");
      el.addClass('rendered')

  $('.scroller').click (e) ->
    e.preventDefault();
    $.scrollTo( $(@).attr('href'), 800 );

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
      else if window.devicePixelRatio > 1
        width = width * 2
      # Replace the image src with a response image size.
      el.attr('src', el.data('src').replace('.jpg', "-#{width}x.jpg"))
      el.addClass('rendered')

  window.loadMapBox();
  $('.video').simpleVideo()
