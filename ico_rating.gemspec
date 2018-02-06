# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ico_rating/version'

Gem::Specification.new do |spec|
  spec.name          = 'ico_rating'
  spec.version       = IcoRating::VERSION
  spec.authors       = ['Kurt Smith']
  spec.email         = ['zippydev@protonmail.com']

  spec.summary       = 'IcoRating ICO expert ratings and information'
  spec.description   = 'IcoRating.com data for the latest cyrptocurrency ICO token ratings and information'
  spec.homepage      = 'https://github.com/kurt-smith/ico_rating'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5.1'
  spec.add_dependency 'http',          '~> 3.0'
  spec.add_dependency 'nokogiri',      '~> 1.8'

  spec.add_development_dependency 'bundler',    '>= 1.14'
  spec.add_development_dependency 'pry',        '>= 0.11'
  spec.add_development_dependency 'rake',       '~> 10.0'
  spec.add_development_dependency 'rspec',      '~> 3.7'
  spec.add_development_dependency 'rubocop',    '>= 0.52'
  spec.add_development_dependency 'simplecov',  '>= 0.15'
  spec.add_development_dependency 'webmock',    '~> 3.2'
end
