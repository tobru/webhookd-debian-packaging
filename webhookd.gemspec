# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webhookd/version'

Gem::Specification.new do |spec|
  spec.name               = "webhookd"
  spec.version            = Webhookd::VERSION
  spec.authors            = ["Tobias Brunner"]
  spec.email              = ["tobias@tobru.ch"]
  spec.summary            = %q{Flexible, configurable universal webhook receiver}
  spec.description        = %q{This app is a flexible, configurable universal webhook receiver, built with sinatra. It can receive a webhook, parse its payload and take action according to the configuration.}
  spec.homepage           = "https://github.com/tobru/webhookd"
  spec.license            = "MIT"

  spec.files              = `git ls-files -z`.split("\x0")
  spec.executables        = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.default_executable = "webhookd"
  spec.test_files         = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths      = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rack-test', '>= 0.6.0'

  spec.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.5'
  spec.add_runtime_dependency 'thor', '~> 0.18', '>= 0.18.1'
  spec.add_runtime_dependency 'thin', '~> 1.6', '>= 1.6.3'

end
