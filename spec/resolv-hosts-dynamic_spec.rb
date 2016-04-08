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
        'aliases'  => [ 'host', 'host2' ],
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
end
