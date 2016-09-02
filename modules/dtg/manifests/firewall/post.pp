# The last rule which does the dropping
class dtg::firewall::post inherits dtg::firewall::default {
  firewall { '999 drop all':
    ensure => absent,
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
  firewall { '999 reject all':
    proto  => 'all',
    action => 'reject',
    before => undef,
    reject => 'icmp-admin-prohibited',
  }
}
