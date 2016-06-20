
node /dns(-\d+)?/ {
  class { 'dtg::minimal': dns_server => true, }

  # unbound is part of the minimal config
  # We just need to stop dhcp overriding the forwarding config and allow access through the firewall
  augeas { 'disable-dhcp-override-of-forward-config':
    context => '/files/etc/default/unbound',
    changes => ['set RESOLVCONF_FORWARDERS false'],
    notify  => Service['unbound'],
    require => Package['unbound'],
  }
  firewall { '030-dns accept tcp 53 (dns) from CL':
    proto  => 'tcp',
    dport  => 53,
    source => $::local_subnet,
    action => 'accept',
  }
  firewall { '031-dns accept udp 53 (dns) from CL':
    proto  => 'udp',
    dport  => 53,
    source => $::local_subnet,
    action => 'accept',
  }

  munin::node::plugin {'unbound_munin_hits':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_queue':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_memory':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_by_type':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_by_class':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_by_opcode':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_by_rcode':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_by_flags':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
  munin::node::plugin {'unbound_munin_histogram':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/network/dns/unbound_',
  }
}
if ( $::monitor ) {
  nagios::monitor { 'dns-0':
    parents    => 'nas04',
    address    => 'dns-0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'dns-servers' ],
  }
  munin::gatherer::async_node { 'dns-0': }
}
