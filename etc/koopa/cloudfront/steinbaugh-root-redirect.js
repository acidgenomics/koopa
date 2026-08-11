function handler(event) {
  var uri = event.request.uri;
  if (uri === '/' || uri === '/index.html') {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        location: { value: 'https://mike.steinbaugh.com/' },
        'cache-control': { value: 'max-age=3600' }
      }
    };
  }
  return event.request;
}
