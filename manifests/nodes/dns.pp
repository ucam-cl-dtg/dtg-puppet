
node /dns(-\d+)?/ {
  include 'dtg::minimal'

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
}
if ( $::monitor ) {
  nagios::monitor { 'dns-0':
    parents    => 'nas04',
    address    => 'dns-0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'dns-servers' ],
  }
  munin::gatherer::configure_node { 'dns-0': }
}
