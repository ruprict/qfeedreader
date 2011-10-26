refresh_feed = (link) ->
  $.ajax('/feeds/' + link.getAttribute('feed_id') + '/refresh', { type: 'POST' })
  spin_and_wait(link)

refresh_all = ->
 $.ajax '/feeds/refresh',  type: 'POST'
 $ '.feed .refresh a'.each (link) ->
    spin_and_wait link

spin_and_wait = (link) ->
  $(link).addClass('refreshing')
  poll_for_update(link.getAttribute('feed_id'), link.getAttribute('last_modified'), link)

poll_for_update =  (feed_id, last_modified, link) ->
  setTimeout ->
    $.get '/feeds/' + feed_id,
      method: 'get'
      requestHeaders:  'If-Modified-Since': last_modified
      onComplete:   (transport) ->
        if transport.status == 304
          poll_for_update(feed_id, last_modified, link)
         else if transport.status == 200
          $('feed_' + feed_id).innerHTML = transport.responseText
         else
          link.innerHTML = 'error'
  ,1000
  

