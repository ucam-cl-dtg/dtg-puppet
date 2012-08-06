Puppet::Parser::Functions::newfunction(:random_number, :type => :rvalue, :doc => "Returns a random number between 0 and number specified") do |args|
  output  =  rand(args[0]);
end
