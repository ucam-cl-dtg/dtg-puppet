class dtg::firewall::zookeeper inherits dtg::firewall::default {
  firewall { '010 accept all zookeeper client traffic':
    proto  => 'tcp',
    dport  => '2181',
    source => $::local_subnet,
    action => 'accept',
  }
  firewall { '011 accept all zookeeper internal traffic':
    proto  => 'tcp',
    dport  => '2888',
    source => $::local_subnet,
    action => 'accept',
  }
  firewall { '011 accept all zookeeper election traffic':
    proto  => 'tcp',
    dport  => '3888',
    source => $::local_subnet,
    action => 'accept',
  }
}
