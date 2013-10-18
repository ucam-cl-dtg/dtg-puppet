# Generate a hour before 8 using the one argument as a seed for generation
require 'digest/md5'

module Puppet::Parser::Functions
  newfunction(:cron_hour, :type => :rvalue) do |args|
    Digest::MD5::hexdigest(args[0]).to_i(16) % 8
  end
end
