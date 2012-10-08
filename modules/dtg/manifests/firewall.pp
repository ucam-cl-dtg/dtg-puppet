#iptables firewalling for nodes
# Default setup
class dtg::firewall::default {
  # These defaults ensure that the persistence command is executed after 
  # every change to the firewall, and that pre & post classes are run in the
  # right order to avoid potentially locking you out of your box during the
  # first puppet run.
  Firewall {
    notify  => Exec['persist-firewall'],
    before  => Class['dtg::firewall::post'],
    require => Class['dtg::firewall::pre'],
  }
  Firewallchain {
    notify  => Exec['persist-firewall'],
  }
}
class dtg::firewall inherits dtg::firewall::default {
  exec { 'persist-firewall':
    command => '/sbin/iptables-save > /etc/iptables.rules',
    refreshonly => true,
  }
  file_line { 'restore iptables':
    ensure => present,
    line   => 'pre-up iptables-restore < /etc/iptables.rules',
    path   => '/etc/network/interfaces',
  }
  # Purge unmanaged firewall resources
  #
  # This will clear any existing rules, and make sure that only rules
  # defined in puppet exist on the machine
#  resources { "firewall":
#    purge => true
#  }
  class {'dtg::firewall::pre':}->
  class {'dtg::firewall::post':}
}

# The first rules which do the accepting
class dtg::firewall::pre inherits dtg::firewall::default {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }->
  firewall { '003 accept all ssh':
    proto   => 'tcp',
    dport   => '22',
    action  => 'accept',
  }->
  firewall { '004 accept munin from muninserver':
    proto   => 'tcp',
    dport   => '4949',
    source  => $::munin_server_ip,
    action  => 'accept',
  }
}
class dtg::firewall::publichttp inherits dtg::firewall::default {
  firewall { '010 accept all http':
    proto   => 'tcp',
    dport   => '80',
    action  => 'accept',
  }
}
class dtg::firewall::privatehttp inherits dtg::firewall::default {
  firewall { '010 accept all http from dtg':
    proto   => 'tcp',
    dport   => '80',
    source  => $::local_subnet,
    action  => 'accept',
  }
}
class dtg::firewall::entropy inherits dtg::firewall::default {
  firewall { '011 accept all entropy requests':
    proto   => 'tcp',
    dport   => '7776',
    action  => 'accept',
    source  => $::local_subnet,
  }
}
class dtg::firewall::git inherits dtg::firewall::default {
  firewall { '012 accept all git':
    proto   => 'tcp',
    dport   => '9418',
    action  => 'accept',
  }
}
class dtg::firewall::80to8080 ($private = true) inherits dtg::firewall::default {
  firewall { '020 redirect 80 to 8080':
    dport   => '80',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => '8080',
  }
  firewall { '020 accept on 8080':
    proto   => 'tcp',
    dport   => '8080',
    action  => 'accept',
    source  => $private ? {
      true  => $::local_subnet,
      false => undef,
    }
  }
}
# The last rule which does the dropping
class dtg::firewall::post inherits dtg::firewall::default {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}
