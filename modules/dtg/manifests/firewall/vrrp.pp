class dtg::firewall::vrrp inherits dtg::firewall::default {
  firewall { '010 accept all multicast vrrp traffic':
    proto  => 'vrrp',
    destination => '224.0.0.0/8',
    action => 'accept',
  }
}
