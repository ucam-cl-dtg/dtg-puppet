class dtg::firewall::zookeeper inherits dtg::firewall::default {
  firewall { '010 accept all zookeeper traffic':
    proto  => 'tcp',
    dport  => '2181',
    action => 'accept',
  }
  firewall { '011 accept all zookeeper election traffic':
    proto  => 'tcp',
    dport  => '2888',
    action => 'accept',
  }
  firewall { '011 accept all zookeeper election traffic':
    proto  => 'tcp',
    dport  => '3888',
    action => 'accept',
  }
}
