# frozen_string_literal: true

require 'resolv'

class Resolv
  class Hosts
    class Dynamic
      def initialize(hosts = [])
        @mutex = Mutex.new
        @name2addr = {}
        @addr2name = {}

        hosts = [hosts] if !hosts.is_a? Array

        hosts.each { |host|
          self.add_address(host)
        }
      end

      ##
      # Adds +host+ to the custom resolver.

      def add_address(host)
        @mutex.synchronize {
          addr = host['addr']
          hostname = host['hostname']
          aliases = host['aliases']

          raise "Must specify 'addr' for host" unless addr
          raise "Must specify 'hostname' for host" unless hostname

          addr.untaint
          hostname.untaint

          # So that aliases can be passed a string or an array of strings
          aliases = [aliases] if aliases.is_a? String

          @addr2name[addr] = [] unless @addr2name.include? addr
          @addr2name[addr] << hostname
          @addr2name[addr] += aliases if aliases
          @name2addr[hostname] = [] unless @name2addr.include? hostname
          @name2addr[hostname] << addr
          aliases.each { |n|
            n.untaint
            @name2addr[n] = [] unless @name2addr.include? n
            @name2addr[n] << addr
          } if aliases
        }
      end

      ##
      # Gets the IP address of +name+ from the custom resolver.

      def getaddress(name)
        each_address(name) { |address| return address }
        raise ResolvError.new("No dynamic hosts entry for name: #{name}")
      end

      ##
      # Gets all IP addresses for +name+ from the custom resolver.

      def getaddresses(name)
        ret = []
        each_address(name) { |address| ret << address }
        return ret
      end

      ##
      # Iterates over all IP addresses for +name+ retrieved from the custom resolver.

      def each_address(name, &proc)
        if @name2addr.include?(name)
          @name2addr[name].each(&proc)
        end
      end

      ##
      # Gets the hostname of +address+ from the custom resolver.

      def getname(address)
        each_name(address) { |name| return name }
        raise ResolvError.new("No dynamic hosts entry for address: #{address}")
      end

      ##
      # Gets all hostnames for +address+ from the custom resolver.

      def getnames(address)
        ret = []
        each_name(address) { |name| ret << name }
        return ret
      end

      ##
      # Iterates over all hostnames for +address+ retrieved from the custom resolver.

      def each_name(address, &proc)
        if @addr2name.include?(address)
          @addr2name[address].each(&proc)
        end
      end
    end
  end
end
