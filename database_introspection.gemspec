# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'database_introspection/version'

Gem::Specification.new do |spec|
  spec.name          = "database_introspection"
  spec.version       = DatabaseIntrospection::VERSION
  spec.authors       = ["L.Briais"]
  spec.email         = ["lbnetid+rb@gmail.com"]
  spec.description   = %q{This gem will generate classes (by default ActiveRecord::Base descendants) from database introspection}
  spec.summary       = %q{Database Introspection}
  spec.homepage      = "https://github.com/lbriais/database_introspection"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "activemodel", ">= 3.2.13"
  spec.add_runtime_dependency "activerecord", ">= 3.2.13"
  spec.add_runtime_dependency "activeresource", ">= 3.2.13"
  spec.add_runtime_dependency "activesupport", ">= 3.2.13"


end
