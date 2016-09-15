# The first rules which do the accepting
class dtg::firewall::pre inherits dtg::firewall::default {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  firewall { '003 accept all ssh':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept',
  }->
  firewall { '004 accept munin from muninserver':
    proto  => 'tcp',
    dport  => '4949',
    source => $::munin_server_ip,
    action => 'accept',
  }
  firewall { '005 accept nfs client':
    proto  => 'tcp',
    dport  => $::nfs_client_port,
    source => $::local_subnet,
    action => 'accept',
  }
}
