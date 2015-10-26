require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

Dir['./spec/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.order = 'random'
  config.run_all_when_everything_filtered = false
end

###

require 'star'

Star.configure do |config|
  config.access_key_id      = ENV['STAR_TEST_AWS_ACCESS_KEY_ID']
  config.secret_access_key  = ENV['STAR_TEST_SECRET_ACCESS_KEY']
  config.bucket             = ENV['STAR_TEST_BUCKET']
  config.location           = ENV['STAR_TEST_LOCATION']
  config.duration           = 30
end
