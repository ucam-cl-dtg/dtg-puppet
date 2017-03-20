class dtg::firewall::isaacsmtp inherits dtg::firewall::default {
  firewall { '010 accept all smtp from Isaac network':
    proto  => 'tcp',
    dport  => '25',
    source => '10.0.0.0/9',
    action => 'accept',
  }
}
