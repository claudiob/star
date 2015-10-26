:star2: :star2: Store archives privately on S3 :star2: :star2:
==============================================================

Star helps you write Ruby apps that need to store files on S3 and retrieve them with expiring URLs.

The **source code** is available on [GitHub](https://github.com/Fullscreen/star) and the **documentation** on [RubyDoc](http://www.rubydoc.info/github/Fullscreen/star/master/Star/Interface).

[![Build Status](http://img.shields.io/travis/Fullscreen/star/master.svg)](https://travis-ci.org/Fullscreen/star)
[![Coverage Status](http://img.shields.io/coveralls/Fullscreen/star/master.svg)](https://coveralls.io/r/Fullscreen/star)
[![Dependency Status](http://img.shields.io/gemnasium/Fullscreen/star.svg)](https://gemnasium.com/Fullscreen/star)
[![Code Climate](http://img.shields.io/codeclimate/github/Fullscreen/star.svg)](https://codeclimate.com/github/Fullscreen/star)
[![Online docs](http://img.shields.io/badge/docs-✓-green.svg)](http://www.rubydoc.info/github/Fullscreen/star/master/Star/File)
[![Gem Version](http://img.shields.io/gem/v/star.svg)](http://rubygems.org/gems/star)


After [configuring your app](#how-to-configure), you can write a file to S3 by running:

```ruby
  file = Star::File.new
  file.open{|f| f << "some text to store in a remote file"}
```

You can successively retrieve the same file from S3 by calling:

```ruby
  url = file.url
```

This will provide a URL that everyone can access *for the next 30 seconds*.

After 30 seconds, access to the file using that URL [will be denied](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-urls.html#private-content-overview-choosing-duration).

Why use Star
============

Star is not the only Ruby library to help developers store archives on S3.
However, most other libraries are [huge](https://rubygems.org/gems/aws-sdk-core) and [heavy on dependencies](https://github.com/fog/fog/blob/master/fog.gemspec#L50-L100).

Star does one thing, and does it well.
The codebase is small and there are no runtime dependencies.
This means less footprint on your app, and code that is easier to read, maintain and upgrade.

How to install
==============

To install on your system, run

    gem install star

To use inside a bundled Ruby project, add this line to the Gemfile:

    gem 'star', '~> 0.1.0'


How to use
==========

To write a file to S3, [configure your app](#how-to-configure), then create a new remote file
instance:

```ruby
file = Star::File.new
```

You can now call any method you would normally use to add content to a
`File`, for instance:

```ruby
file.open do |f|
  f << "append some text"
  f.write "write some other text"
  f.writeln "write a line of text"
end
```

Once the file is closed, Star will automatically upload it to S3.

To read the same file from S3, get its URL by calling

```ruby
file.url
```

By default, this URL will only be publicly available for 30 seconds.
This is useful to let your users download the file, while preventing them
from sharing the URL and having other (unauthenticated) users download it.

Options
-------

When you create a new remote file instance, you can set these options:

* `name`: the file name (defaults to `'attachment'`)
* `content_type`: the content type for the file (defaults to `'application/octet-stream'`)
* `folder`: the remote folder where to store the file (defaults to `'attachments'`)

For instance, you can call `File.new` with these options:

```ruby
Star::File.new name: 'test.csv', content_type: 'text/csv', folder: 'spreadsheets'
```

How to configure
================

In order to use Star you must have an [S3 account](https://aws.amazon.com/s3).

Log into your account to retrieve your access key ID, secret access key and
bucket name, then add the following code to your app:

```ruby
Star.configure do |config|
  config.access_key_id = '<YOUR S3 ACCESS KEY ID>'
  config.secret_access_key = '<YOUR S3 SECRET ACCESS KEY>'
  config.bucket = '<YOUR S3 BUCKET NAME>'
end
```

Make sure that this code is run *before* you use Star.
For instance, in a Rails app, you can store this code in `config/initializers/star.rb`.

Star also provide two options that you can set in your configuration:

* `duration` specifies how many seconds the expiring URLs should be valid for (default: `30`)
* `location` specifies the subfolder of your bucket where files should be stored (default: `'/'`)
* `remote` specifies that files will be stored remotely on S3 (default: `true`)

For instance, your configuration could look like this:

```ruby
Star.configure do |config|
  config.access_key_id = '<YOUR S3 ACCESS KEY ID>'
  config.secret_access_key = '<YOUR S3 SECRET ACCESS KEY>'
  config.bucket = '<YOUR S3 BUCKET NAME>'
  config.duration = 60
  config.location = 'production/uploads'
end
```

Configuring with environment variables
--------------------------------------

As an alternative to the approach above, you can configure your app with
environment variables. For instance, setting the following variables:

```bash
export AWS_ACCESS_KEY_ID="<YOUR S3 ACCESS KEY ID>"
export AWS_SECRET_ACCESS_KEY="<YOUR S3 SECRET ACCESS KEY>"
export AWS_BUCKET="<YOUR S3 BUCKET NAME>"
export STAR_DURATION="60"
export STAR_LOCATION="production/uploads"
```

is equivalent to configuring your app with the initializer above.

How to store files locally
==========================

If you set `Star.configuration.remote` to `false`, then your files will be
stored locally, rather than remotely on S3.

This is very convenient if you use Star in a Rails application.
By adding the following lines to `config/environments/development.rb`:

```ruby
Star.configure do |config|
  config.remote = false
  config.location = Rails.public_path
end
```

all your files will be stored in your `public/` folder while developing.
In production, your files will still be stored on S3.

Your Rails controller/action that redirects to a file might look like this:


```ruby
if Star.remote?
  redirect_to file.url
else
  send_file file.path, type: file.content_type
end
```

How to contribute
=================

If you find that a method is missing, fork the project, add the missing code,
write the appropriate tests, then submit a pull request, and it will gladly
be merged!

In order to test, you need to have access to a S3 account that will be used
to upload and download test files.

Set the following environment variables to match your S3 account, then run
`rspec` to run the tests:

```bash
export STAR_TEST_AWS_ACCESS_KEY_ID="<YOUR TEST S3 ACCESS KEY ID>"
export STAR_TEST_SECRET_ACCESS_KEY="<YOUR TEST S3 SECRET ACCESS KEY>"
export STAR_TEST_BUCKET="<YOUR TEST S3 BUCKET NAME>"
export STAR_TEST_LOCATION="<YOUR TEST S3 FOLDER>"
```

How to release new versions
===========================

If you are a manager of this project, remember to upgrade the [Star gem](http://rubygems.org/gems/star)
whenever a new feature is added or a bug gets fixed.

Make sure all the tests are passing on [Travis CI](https://travis-ci.org/Fullscreen/star),
document the changes in CHANGELOG.md and README.md, bump the version, then run

    rake release

Remember that the star gem follows [Semantic Versioning](http://semver.org).
Any new release that is fully backward-compatible should bump the *patch* version (0.0.x).
Any new version that breaks compatibility should bump the *minor* version (0.x.0)
