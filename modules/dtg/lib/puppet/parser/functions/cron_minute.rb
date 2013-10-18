# Generate a minute using the one argument as a seed for generation
require 'md5'

module Puppet::Parser::Functions
  newfunction(:cron_minute, :type => :rvalue) do |args|
    Digest::MD5::hexdigest(args[0]).to_i(16) % 60
  end
end
