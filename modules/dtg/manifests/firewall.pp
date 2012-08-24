#iptables firewalling for nodes
# Default setup
class dtg::firewall {
  exec { 'persist-firewall':
    command => '/sbin/iptables-save > /etc/iptables/rules.v4',
    refreshonly => true,
  }
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
  # Purge unmanaged firewall resources
  #
  # This will clear any existing rules, and make sure that only rules
  # defined in puppet exist on the machine
#  resources { "firewall":
#    purge => true
#  }
}

# The first rules which do the accepting
class dtg::firewall::pre {
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
class dtg::firewall::publichttp {
  firewall { '010 accept all http':
    proto   => 'tcp',
    dport   => '80',
    action  => 'accept',
  }
}
class dtg::firewall::privatehttp {
  firewall { '010 accept all http from dtg':
    proto   => 'tcp',
    dport   => '80',
    source  => $::local_subnet,
    action  => 'accept',
  }
}
class dtg::firewall::entropy {
  firewall { '011 accept all entropy requests':
    proto   => 'tcp',
    dport   => '7776',
    action  => 'accept',
    source  => $::local_subnet,
  }
}
# The last rule which does the dropping
class dtg::firewall::post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}
