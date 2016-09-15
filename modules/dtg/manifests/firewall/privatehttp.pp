class dtg::firewall::privatehttp inherits dtg::firewall::default {
  firewall { '010 accept all http from CL':
    proto  => 'tcp',
    dport  => '80',
    source => $::local_subnet,
    action => 'accept',
  }
}
