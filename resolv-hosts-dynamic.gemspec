# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'resolv-hosts-dynamic'
  spec.version       = '0.0.2'
  spec.authors       = ['Chris Reeves']
  spec.email         = ['chris.reeves@york.ac.uk']
  spec.summary       = "Dynamic in-memory 'hosts' file for resolving hostnames."
  spec.description   = "Dynamic in-memory 'hosts' file for resolving hostnames. Injects entries into an in-memory 'hosts' file which can later be used for name resolution without having to modify the system hosts file. This is an extension to the standard ruby Resolv library and is useful for over-riding name resolution during testing."
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 1.26'
end
