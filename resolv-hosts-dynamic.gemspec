# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'resolv-hosts-dynamic'
  spec.version       = '1.1.0'
  spec.authors       = ['Chris Reeves']
  spec.email         = ['chris.reeves@iname.com']
  spec.summary       = "Dynamic in-memory 'hosts' file for resolving hostnames."
  spec.description   = <<-DESCRIPTION
    Dynamic in-memory 'hosts' file for resolving hostnames. Injects entries
    into an in-memory 'hosts' file which can later be used for name resolution
    without having to modify the system hosts file. This is an extension to
    the standard ruby Resolv library and is useful for over-riding name
    resolution during testing.
  DESCRIPTION
  spec.homepage      = 'https://github.com/chris-reeves/gem-resolv-hosts-dynamic'
  spec.license       = 'MIT'

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/chris-reeves/gem-resolv-hosts-dynamic',
    'changelog_uri'         => 'https://github.com/chris-reeves/gem-resolv-hosts-dynamic/blob/master/CHANGELOG.md',
    'source_code_uri'       => 'https://github.com/chris-reeves/gem-resolv-hosts-dynamic',
    'bug_tracker_uri'       => 'https://github.com/chris-reeves/gem-resolv-hosts-dynamic/issues',
    'rubygems_mfa_required' => 'true',
  }

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0' # rubocop:disable Gemspec/RequiredRubyVersion
end
