class dtg::firewall::entropy inherits dtg::firewall::default {
  firewall { '011 accept all entropy requests':
    proto  => 'tcp',
    dport  => '7776',
    action => 'accept',
    source => $::local_subnet,
  }
}
