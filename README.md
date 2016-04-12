# Resolv::Hosts::Dynamic

Dynamic in-memory 'hosts' file for resolving hostnames. Injects entries into
an in-memory 'hosts' file which can later be used for name resolution without
having to modify the system hosts file. This is an extension to the standard
ruby Resolv library and is useful for over-riding name resolution during
testing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resolv-hosts-dynamic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resolv-hosts-dynamic

## Usage

### Adding entries to the dynamic host resolver

Entries can be added during class instantiation or at any point afterwards
(via the `add_address` method) if we've still got a handle on the object. An
entry consists of a hash with the `addr` and `hostname` properties, plus an
optional `aliases` property. Entries added during class instantiation can be
in the form of a single entry or an array of entries. `add_address` only
accepts a single entry at a time.

```ruby
require 'resolv-hosts-dynamic'

res = Resolv::Hosts::Dynamic.new([
  {
    'addr'     => '127.1.2.3',
    'hostname' => 'host.example.com',
  },
  {
    'addr'     => '127.4.5.6',
    'hostname' => 'host2.example.com',
    'aliases'  => 'host2',
  },
])

res.add_address({
  'addr'     => '127.7.8.9',
  'hostname' => 'host3.example.com',
  'aliases'  => [ 'host3', 'www.example.com' ],
})
```

### Resolving hostnames/IPs

This class can be used on its own or within the standard ruby Resolv library.

On its own:

```ruby
require 'resolv-hosts-dynamic'

res = Resolv::Hosts::Dynamic.new({
  'addr'     => '127.1.2.3',
  'hostname' => 'host.example.com',
})

res.getaddress('host.example.com')
res.getname('127.1.2.3')
```

Within the standard ruby Resolv library:

```ruby
require 'resolv-hosts-dynamic'

res = Resolv.new([
  Resolv::Hosts::Dynamic.new({
    'addr'     => '127.1.2.3',
    'hostname' => 'host.example.com',
  }),
  Resolv::Hosts.new,
  Resolv::DNS.new,
])

res.getaddress('host.example.com')
res.getname('127.1.2.3')

res.getaddresses('rubygems.org')
```

Replacing the default resolver in the standard ruby Resolv library (using
`resolve-replace`):

```ruby
require 'resolv-hosts-dynamic'
require 'resolv-replace'

dynres = Resolv::Hosts::Dynamic.new({
  'addr'     => '127.1.2.3',
  'hostname' => 'host.example.com',
})

Resolv::DefaultResolver.replace_resolvers([
  dynres,
  Resolv::Hosts.new,
  Resolv::DNS.new,
])

Resolv.getaddress('host.example.com')
Resolv.getname('127.1.2.3')
Resolv.getaddresses('www.google.com')

dynres.add_address({
  'addr'     => '127.4.5.6',
  'hostname' => 'www.google.com',
})

Resolv.getaddresses('www.google.com')
```

## Contributing

1. Fork it ( https://github.com/chris-reeves/gem-resolv-hosts-dynamic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
