class dtg::firewall::git inherits dtg::firewall::default {
  firewall { '012 accept all git':
    proto  => 'tcp',
    dport  => '9418',
    action => 'accept',
  }
}
