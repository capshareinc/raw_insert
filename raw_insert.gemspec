# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raw_insert/version'

Gem::Specification.new do |spec|
  spec.name          = "raw_insert"
  spec.version       = RawInsert::VERSION
  spec.authors       = ["paulbaker3"]
  spec.email         = ["paul.baker.3@gmail.com"]
  spec.summary       = %q{Got lots of data? Raw insert it!}
  spec.description   = %q{Ruby gem to dynamically insert ruby models via raw insert statement.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
