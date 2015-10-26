# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'star/version'

Gem::Specification.new do |spec|
  spec.name          = 'star'
  spec.version       = Star::VERSION
  spec.authors       = ['claudiob', 'Jeremy Cohen Hoffing']
  spec.email         = ['claudiob@gmail.com', 'jcohenhoffing@gmail.com']
  spec.summary       = %q{Write files to S3, read them with expiring URLs}
  spec.description   = %q{Star provides a File class to write files to S3
    as though they were local files, and to retrieve them from S3 with a URL
    that expires after 30 seconds, so it cannot be shared publicly.}
  spec.homepage      = 'https://github.com/fullscreen/star'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'coveralls', '~> 0.8.2'
  spec.add_development_dependency 'pry-nav', '~> 0.2.4'
end
