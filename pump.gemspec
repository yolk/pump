# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pump/version"

Gem::Specification.new do |gem|
  gem.name          = "pump"
  gem.version       = Pump::VERSION
  gem.authors       = ["Sebastian Munz"]
  gem.email         = ["sebastian@yo.lk"]
  gem.description   = %q{Fast but inflexible XML and JSON encoding for ruby objects.}
  gem.summary       = %q{Fast but inflexible XML and JSON encoding for ruby objects.}
  gem.homepage      = "https://github.com/yolk/pump"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport",           ">= 4.0"
  gem.add_dependency "oj",                      ">= 3.0"
  gem.add_development_dependency "rspec",       ">= 3.2"
  gem.add_development_dependency "rspec-its"
end
