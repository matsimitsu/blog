//= require simplevideo
//= require visible
//= require scrollto
//= require rowgrid
//= require mapbox

@check_scroll = undefined

$(window).on 'scroll', ->
  clearTimeout(@check_scroll)
  @check_scroll = setTimeout(doneScrolling, 100)

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

  height = $(window).height()
  $('article.trip header.big').height("#{height}px")
  $('article.post header.big').height("#{Math.round(height * 0.6)}px")

  $('.scroller').click (e) ->
    e.preventDefault();
    $.scrollTo( $(@).attr('href'), 800 );

  $('.photo-row').each ->
    $(@).collagePlus()

  window.loadMapBox();
