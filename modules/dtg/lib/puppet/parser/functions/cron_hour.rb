# Generate a hour before 8 using the one argument as a seed for generation
require 'md5'

module Puppet::Parser::Functions
  newfunction(:cron_hour, :type => :rvalue) do |args|
    MD5.new(args[0]).to_s.hex % 8
  end
end
