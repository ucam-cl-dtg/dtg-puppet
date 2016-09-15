class dtg::firewall::avahi inherits dtg::firewall::default {
  firewall { '040-build accept avahi udp 5353':
    proto  => 'udp',
    dport  => 5353,
    action => 'accept',
  }
}
