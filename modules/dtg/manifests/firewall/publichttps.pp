class dtg::firewall::publichttps inherits dtg::firewall::default {
  firewall { '013 accept all https':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }
}
