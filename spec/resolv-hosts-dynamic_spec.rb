# frozen_string_literal: true

require 'spec_helper'

describe Resolv::Hosts::Dynamic do
  describe '#initialize' do
    context 'with an empty params list' do
      res = Resolv::Hosts::Dynamic.new

      it 'should have empty lookup maps' do
        expect(
          res.instance_variable_get(:@name2addr).empty?
        ).to eq true

        expect(
          res.instance_variable_get(:@addr2name).empty?
        ).to eq true
      end
    end

    context 'with a single (hash) param' do
      res = Resolv::Hosts::Dynamic.new({
        'addr'     => '127.1.2.3',
        'hostname' => 'host.example.com',
      })

      it 'should have a single record in the name2addr map' do
        expect(
          res.instance_variable_get(:@name2addr).size
        ).to eq 1
      end

      it 'should have a single record in the addr2name map' do
        expect(
          res.instance_variable_get(:@addr2name).size
        ).to eq 1
      end
    end

    context 'with a single (array) param' do
      res = Resolv::Hosts::Dynamic.new([
        {
          'addr'     => '127.1.2.3',
          'hostname' => 'host.example.com',
        },
        {
          'addr'     => '127.4.5.6',
          'hostname' => 'host2.example.com',
        },
        {
          'addr'     => '127.7.8.9',
          'hostname' => 'host3.example.com',
        },
      ])

      it 'should have three records in the name2addr map' do
        expect(
          res.instance_variable_get(:@name2addr).size
        ).to eq 3
      end

      it 'should have three records in the addr2name map' do
        expect(
          res.instance_variable_get(:@addr2name).size
        ).to eq 3
      end
    end
  end

  describe '#add_address' do
    context 'with a simple hostname -> address map' do
      res = Resolv::Hosts::Dynamic.new

      res.add_address({
        'addr'     => '127.1.2.3',
        'hostname' => 'host.example.com',
      })

      it 'should map the hostname to the address' do
        expect(
          res.instance_variable_get(:@name2addr)['host.example.com']
        ).to eq(['127.1.2.3'])
      end

      it 'should map the address to the hostname' do
        expect(
          res.instance_variable_get(:@addr2name)['127.1.2.3']
        ).to eq(['host.example.com'])
      end
    end

    context 'with a hostname plus a single alias' do
      res = Resolv::Hosts::Dynamic.new

      res.add_address({
        'addr'     => '127.1.2.3',
        'hostname' => 'host.example.com',
        'aliases'  => 'host',
      })

      it 'should map the hostname to the address' do
        expect(
          res.instance_variable_get(:@name2addr)['host.example.com']
        ).to eq(['127.1.2.3'])
      end

      it 'should map the alias to the address' do
        expect(
          res.instance_variable_get(:@name2addr)['host']
        ).to eq(['127.1.2.3'])
      end

      it 'should map the address to the hostname and alias' do
        expect(
          res.instance_variable_get(:@addr2name)['127.1.2.3']
        ).to eq(['host.example.com', 'host'])
      end
    end

    context 'with a hostname plus multiple aliases' do
      res = Resolv::Hosts::Dynamic.new

      res.add_address({
        'addr'     => '127.1.2.3',
        'hostname' => 'host.example.com',
        'aliases'  => %w[host host2],
      })

      it 'should map the hostname to the address' do
        expect(
          res.instance_variable_get(:@name2addr)['host.example.com']
        ).to eq(['127.1.2.3'])
      end

      it 'should map both aliases to the address' do
        expect(
          res.instance_variable_get(:@name2addr)['host']
        ).to eq(['127.1.2.3'])

        expect(
          res.instance_variable_get(:@name2addr)['host2']
        ).to eq(['127.1.2.3'])
      end

      it 'should map the address to the hostname and the aliases' do
        expect(
          res.instance_variable_get(:@addr2name)['127.1.2.3']
        ).to eq(['host.example.com', 'host', 'host2'])
      end
    end

    context 'with multiple hostnames for the same address added in separate calls' do
      res = Resolv::Hosts::Dynamic.new

      res.add_address({
        'addr'     => '127.1.2.3',
        'hostname' => 'host.example.com',
      })

      res.add_address({
        'addr'     => '127.1.2.3',
        'hostname' => 'host2.example.com',
      })

      it 'should map both hostnames to the address' do
        expect(
          res.instance_variable_get(:@name2addr)['host.example.com']
        ).to eq(['127.1.2.3'])

        expect(
          res.instance_variable_get(:@name2addr)['host2.example.com']
        ).to eq(['127.1.2.3'])
      end

      it 'should map the address to both hostnames' do
        expect(
          res.instance_variable_get(:@addr2name)['127.1.2.3']
        ).to eq(['host.example.com', 'host2.example.com'])
      end
    end

    context 'with multiple addresses for the same hostname' do
      res = Resolv::Hosts::Dynamic.new

      res.add_address({
        'addr'     => '127.1.2.3',
        'hostname' => 'host.example.com',
      })

      res.add_address({
        'addr'     => '127.4.5.6',
        'hostname' => 'host.example.com',
      })

      it 'should map the hostname to both addresses' do
        expect(
          res.instance_variable_get(:@name2addr)['host.example.com']
        ).to eq(['127.1.2.3', '127.4.5.6'])
      end

      it 'should map both addresses to the hostname' do
        expect(
          res.instance_variable_get(:@addr2name)['127.1.2.3']
        ).to eq(['host.example.com'])

        expect(
          res.instance_variable_get(:@addr2name)['127.4.5.6']
        ).to eq(['host.example.com'])
      end
    end
  end

  # takes the first ip if there are multiple IPs
  describe 'resolver methods' do
    dynres = Resolv::Hosts::Dynamic.new

    # address with multiple names
    dynres.add_address({
      'addr'     => '127.1.2.3',
      'hostname' => 'host.example.com',
      'aliases'  => 'host',
    })

    # name with multiple addresses
    dynres.add_address({
      'addr'     => '127.4.5.6',
      'hostname' => 'host.example.com',
    })

    res = Resolv.new([dynres])

    describe '#getaddress' do
      it 'resolves host.example.com to a single address' do
        expect(
          res.getaddress('host.example.com')
        ).to eq '127.1.2.3'
      end

      it 'raises ResolvError if the name can not be looked up' do
        expect{
          res.getaddress('no.such.host.')
        }.to raise_error(Resolv::ResolvError)
      end
    end

    describe '#getaddresses' do
      it 'resolves host.example.com to multiple addresses' do
        expect(
          res.getaddresses('host.example.com')
        ).to eq ['127.1.2.3', '127.4.5.6']
      end

      it 'resolves to no addresses if the name can not be looked up' do
        expect(
          res.getaddresses('no.such.host.').empty?
        ).to be true
      end
    end

    describe '#getname' do
      it 'resolves 127.1.2.3 to a single hostname' do
        expect(
          res.getname('127.1.2.3')
        ).to eq 'host.example.com'
      end

      it 'raises ResolvError if the address can not be looked up' do
        expect{
          res.getname('127.7.8.9')
        }.to raise_error(Resolv::ResolvError)
      end
    end

    describe '#getnames' do
      it 'resolves 127.1.2.3 to a single hostname' do
        expect(
          res.getnames('127.1.2.3')
        ).to eq ['host.example.com', 'host']
      end

      it 'resolves to no hostnames if the address can not be looked up' do
        expect(
          res.getnames('127.7.8.9').empty?
        ).to be true
      end
    end
  end
end
