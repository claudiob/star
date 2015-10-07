# What is Star?

Use Star if your ruby application needs to write files to S3 and retrieve them with URLs that expire so users cannot share them.

# Why use Star and not gems like...

Other gems like aws-sdk and fog do this but they are large and have lots of dependencies.
Star has no dependencies.

# How to install

Add this line to your application's Gemfile:

```ruby
gem 'star'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install star

## Usage

blah

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/star.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## How to test

Set your environment variables in spec_helper
