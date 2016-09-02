class dtg::firewall::rsyslog inherits dtg::firewall::default {
  firewall { '014 redirect 514 to 5514':
    dport   => '514',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    proto   => 'tcp',
    iniface => 'eth0',
    toports => '5514',
  }
  firewall { '014 udp redirect 514 to 5514':
    dport   => '514',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    proto   => 'udp',
    iniface => 'eth0',
    toports => '5514',
  }
  firewall { '015 accept all TCP rsyslog from dtg':
    proto  => 'tcp',
    dport  => '5514',
    action => 'accept',
    source => $::local_subnet,
  }

  firewall { '016 accept all UDP rsyslog from dtg':
    proto  => 'udp',
    dport  => '5514',
    action => 'accept',
    source => $::local_subnet,
  }
}
