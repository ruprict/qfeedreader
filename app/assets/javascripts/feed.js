var poll_for_update, refresh_all, refresh_feed, spin_and_wait;
refresh_feed = function(link) {
  $.ajax('/feeds/' + link.getAttribute('feed_id') + '/refresh', {
    type: 'POST'
  });
  return spin_and_wait(link);
};
refresh_all = function() {
  $.ajax('/feeds/refresh', {
    type: 'POST'
  });
  return $('.feed .refresh a'.each(function(link) {
    return spin_and_wait(link);
  }));
};
spin_and_wait = function(link) {
  $(link).addClass('refreshing');
  return poll_for_update(link.getAttribute('feed_id'), link.getAttribute('last_modified'), link);
};
poll_for_update = function(feed_id, last_modified, link) {
  return setTimeout(function() {
    return $.get('/feeds/' + feed_id, {
      method: 'get',
      requestHeaders: {
        'If-Modified-Since': last_modified,
        onComplete: function(transport) {
          if (transport.status === 304) {
            return poll_for_update(feed_id, last_modified, link);
          } else if (transport.status === 200) {
            return $('feed_' + feed_id).innerHTML = transport.responseText;
          } else {
            return link.innerHTML = 'error';
          }
        }
      }
    });
  }, 1000);
};