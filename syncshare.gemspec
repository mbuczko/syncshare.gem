# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'syncshare/version'

Gem::Specification.new do |spec|
  spec.name          = "syncshare"
  spec.version       = Syncshare::VERSION
  spec.authors       = ["Michal Buczko"]
  spec.email         = ["michal.buczko@gmail.com"]
  spec.description   = %q{This gem allows defining SyncShare workers by providing concise DSL and underlaying communication with AMQP server}
  spec.summary       = %q{DSL for ruby-based SyncShare workers.}
  spec.homepage      = "https://github.com/mbuczko/syncshare"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "amqp"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
