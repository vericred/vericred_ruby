# Vericred

[![Code Climate](https://codeclimate.com/repos/562a2857e30ba04788014399/badges/07d05b9b6da4fdd2aca6/gpa.svg)](https://codeclimate.com/repos/562a2857e30ba04788014399/feed)

[![Build Status](https://travis-ci.org/vericred/vericred_ruby.svg?branch=master)](https://travis-ci.org/vericred/vericred_ruby)

A client gem to interact with the Vericred API.  It provides useful helpers for:

- Futures
- Sideloading data
- Pagination (TODO)

## Additional Documentation
Full generated API docs here.  Documentation of the REST API itself here.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vericred'
```

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install vericred

### With Rails

Add a configuration block in `config/initializers/vericred.rb`
```ruby
Vericred.configure do |config|
  config.api_key = ENV['VERICRED_API_KEY']
end
```

## Usage

### Retrieving an Individual Record
```ruby
Vericred::Provider.find(npi) # => Vericred::Provider
```

### Retrieving a List of Records
```ruby
Vericred::Provider.search(search_term: 'foo', zip_code: '11215')
  # => [Vericred::Provider, Vericred::Provider]
```

#### Searching for Plans
When searching for Plans, you may supply one or more applicants to retrieve
pricing.  The `smoker` flag only need be supplied if it is true.

```ruby
Vericred::Plan.search(
  zip_code: '11215',
  fips_code: '36047',
  market: 'individual',
  applicants: [
    { age: 31 },
    { age: 42, smoker: true }
  ],
  providers: [
    { npi: 1841293990 },
    { npi: 1740283779 }
  ]
)
  # => [Vericred::Plan<premium=401.23>, Vericred::Plan<premium=501.13>]
```

### Sideloaded data
Sideloaded data is automatically added to the object found.  For example,
`Vericred::ZipCounty` includes `Vericred::ZipCode` and `Vericred::County`
with the following response (simplified)
```json
{
  "zip_counties": [{"id": 1, "zip_code_id": 2, "county_id": 3}],
  "counties": [{"id": 3, "name": "County"}],
  "zip_codes": [{"id": 2, "code": "12345"}]
}
```

When we `.search` for `Vericred::ZipCounties` the records returned already 
have access to their `Vericred::County` and `Vericred::ZipCode`

```ruby
zip_counties = Vericred::ZipCounty.search(zip_prefix: '12345')
zip_counties.first.county.name # => County
zip_counties.first.zip_code.code # => 12345
```

### Using Futures
Any individual or list of records can be found using a Future.  This
allows you to make a request early in the execution of your codepath 
and allow the API to return a result without blocking execution.  It also
allows you to make requests to the API in parallel.

```ruby
futures = [npi1, npi2, npi3]
            .map { |id| Vericred::Provider.future.find(npi) }
# do some other stuff in the meantime, then call #value to get the result
providers = futures.map(&:value)
```

### Error Handling

Generic error handling:
```ruby
begin
  Vericred::Provider.find(npi)
rescue Vericred::Error => e
  # Retry or do something else
end
```

Handling each possible error
```ruby
begin
  Vericred::Provider.find(npi)
rescue Vericred::UnauthenticatedError => e
  # No credentials supplied
rescue Vericred::UnauthorizedError => e
  # Invalid credentials
rescue Vericred::UnprocessableEntityError => e
  # Invalid parameters have been specified
rescue Vericred::UnknownError => e
  # Something else has gone wrong - see e.errors for details
end
```
Every instance of `Vericred::Error` has an `#errors` method, which returns
the parsed error messages from the server.  They are in the format.
```json
{
  "errors": {
    "field_or_category": ["list", "of", "things", "wrong"]
  }
}
```

When parsed, they can be accessed like:
```ruby
begin
  Vericred::Provider.find(npi)
rescue Vericred::Error => e
  e.errors.field_or_category.join(', ') # "list, of, things, wrong"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/vericred. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

