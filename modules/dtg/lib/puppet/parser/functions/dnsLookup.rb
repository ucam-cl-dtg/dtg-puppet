# dnsLookup.rb
# does a DNS lookup and returns an array of strings of the results
# Taken from: http://geek.jasonhancock.com/2011/04/20/doing-a-dns-lookup-inside-your-puppet-manifest/
# Would probably be MIT licenced if we asked: https://github.com/jasonhancock/puppet-facts
 
require 'resolv'
 
module Puppet::Parser::Functions
    newfunction(:dnsLookup, :type => :rvalue) do |args|
        result = []
        result = Resolv.new.getaddresses(args[0])
        return result
    end
end
