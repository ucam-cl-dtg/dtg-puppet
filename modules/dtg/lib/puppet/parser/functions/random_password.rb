Puppet::Parser::Functions::newfunction(:random_password, :type => :rvalue, :doc => "Returns a random password") do |args|
  o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;
  output  =  (0..15).map{ o[rand(o.length)]  }.join;
end
