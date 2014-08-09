# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pocket_rocket/version'

Gem::Specification.new do |spec|
  spec.name        = "pocket_rocket"
  spec.version     = PocketRocket::VERSION
  spec.authors     = ["Mike Hagedorn"]
  spec.email       = ["mike@silverchairsolutions.com"]
  spec.summary     = %q{Simple command line utility for calculating rocket altitudes}
  spec.description = %q{command line utility for calculating rocket altitudes}
  spec.homepage    = ""
  spec.license     = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("interpolate")
  spec.add_dependency("thor")
  spec.add_dependency("formatador")

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
