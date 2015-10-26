# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vericred/version'

Gem::Specification.new do |spec|
  spec.name          = "vericred"
  spec.version       = Vericred::VERSION
  spec.authors       = ["Dan Langevin"]
  spec.email         = ["dlangevin@vericred.com"]

  spec.summary       = %q{Vericred API Client}
  spec.description   = %q{Client to interact with the Vericred API}
  spec.homepage      = "https://github.com/vericred/vericred_ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "httpclient"
  spec.add_dependency "celluloid"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "guard-rspec"
end
