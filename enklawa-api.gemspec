# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enklawa/api/version'

Gem::Specification.new do |spec|
  spec.name          = "enklawa"
  spec.version       = Enklawa::Api::VERSION
  spec.authors       = ["Arkadiusz Buras"]
  spec.email         = ["macbury@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "pry"
  spec.add_dependency "thor"
  spec.add_dependency "sanitize"
  spec.add_dependency "nokogiri"
  spec.add_dependency "feedjira", "~> 1.4"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-rspec"
end
