# Generate a minute using the one argument as a seed for generation
require 'md5'

module Puppet::Parser::Functions
  newfunction(:cron_minute, :type => :rvalue) do |args|
    MD5.new(args[0]).to_s.hex % 60
  end
end
