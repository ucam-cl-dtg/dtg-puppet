module Puppet::Parser::Functions 
  newfunction(:zfs_shareopts,:type => :rvalue, :doc => <<-EOS
Returns a string suitable for the sharenfs option on zfs. 
First argument should be an array of hostnames (or IPs) to grant readonly access to
Second argument should be an array of hostnames (or IPs) to grant readwrite access to
Third argument is (optionally) any additional rules you want to add (as a string)
EOS
              ) do |args|
    # if you are wondering about function_dnsLookup([args]) then see here: https://docs.puppet.com/guides/custom_functions.html#calling-functions-from-functions
    names = args[0].map { |name| "ro=@" + function_dnsLookup([name])[0] }
    names.concat(args[1].map { |name| "rw=@"+ function_dnsLookup([name])[0] })
    if args.length == 3
      names.push(args[2])
    end
    names.push("async")
    names.join(",")
  end
end
