class dtg::firewall::publichttp inherits dtg::firewall::default {
  firewall { '010 accept all http':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
