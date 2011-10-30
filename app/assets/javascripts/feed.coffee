refresh_feed = null
refresh_feed = (link) ->
  $.ajax('/feeds/' + link.getAttribute('feed_id') + '/refresh', { type: 'POST' })
  spin_and_wait(link)

refresh_all = ->
  $.ajax '/feeds/refresh'
    type: 'POST'
  $('.feed .refresh a').each (ind,link) ->
    spin_and_wait link

spin_and_wait = (link) ->
  $(link).addClass('refreshing')
  poll_for_update(link.getAttribute('feed_id'), link.getAttribute('last_modified'), link)

poll_for_update =  (feed_id, last_modified, link) ->
  setTimeout ->
    $.ajax 
      url: '/feeds/' + feed_id
      ifModified: true
      headers:  
        'If-Modified-Since': last_modified
      success:   (data, txtStatus, xhr) ->
        if xhr.status == 304
          poll_for_update(feed_id, last_modified, link)
         else if xhr.status == 200
          $('#feed_' + feed_id).html(data)
         else
          link.innerHTML = 'error'
  ,1000
  

