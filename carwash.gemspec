# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carwash/version'

Gem::Specification.new do |spec|
  spec.name          = "carwash"
  spec.version       = Carwash::VERSION
  spec.authors       = ["Nathan Clark"]
  spec.email         = ["nathan.clark@tokenshift.com"]
  spec.license       = "MIT"

  spec.summary       = %q{Scrubs potentially sensitive values from log entries.}
  spec.homepage      = "http://github.com/tokenshift/ruby_carwash"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
end
