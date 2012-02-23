# Sagamore Client

This is the Sagamore Client library for Ruby. It provides access to the Sagamore HTTP API.

It is a wrapper around the [Patron](http://toland.github.com/patron/) HTTP client library.

## Examples

### Connecting
```ruby
client = Sagamore::Client.new 'http://example.sagamore.us',
  :username => 'user',
  :password => 'secret'
```

### Resource oriented
```ruby
resource = client[:items][1234]
response = resource.get
```

### URI oriented
```ruby
response = client.get '/items/1234'
```

### Request body

If the request body is a Hash, it will automatically be serialized as JSON. Otherwise, it is
passed through untouched:

```ruby
# this:
client[:some_collection].post :a => 1, :b => 2

# is equivalent to this:
client[:some_collection].post '{"a":1,"b":2}'
```

### Bang variants

All HTTP request methods have a bang variant that raises an exception on failure:

```ruby
response = client[:i_dont_exist].get
puts response.status
# 404

client[:i_dont_exist].get!
# Raises Sagamore::Client::RequestFailed exception
```
