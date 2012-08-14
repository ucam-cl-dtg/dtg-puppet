# escapeRegexp.rb
# Escape a regular expression e.g. '\*?{}.' => '\\\*\?\{\}\.' 
 
module Puppet::Parser::Functions
    newfunction(:escapeRegexp, :type => :rvalue) do |args|
        return Regexp.escape(args[0])
    end
end
