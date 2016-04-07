# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "resolv-hosts-dynamic"
  spec.version       = "0.0.1"
  spec.authors       = ["Chris Reeves"]
  spec.email         = ["chris.reeves@york.ac.uk"]
  spec.summary       = %q{Dynamic in-memory 'hosts' file for resolving hostnames.}
  spec.description   = %q{Dynamic in-memory 'hosts' file for resolving hostnames. Injects entries into an in-memory 'hosts' file which can later be used for name resolution without having to modify the system hosts file. This is useful for over-riding name resolution during testing.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
