# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubcat/version'

Gem::Specification.new do |spec|
  spec.name          = "rubcat"
  spec.version       = Rubcat::VERSION
  spec.authors       = ["polamjag"]
  spec.email         = ["s@polamjag.info"]

  spec.summary       = %q{pidcat, pretty adb logcat in Ruby}
  spec.description   = %q{pidcat, pretty adb logcat in Ruby. without any dependencies. can be installed and updated with gem command!}
  spec.homepage      = "https://github.com/rubcat"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
