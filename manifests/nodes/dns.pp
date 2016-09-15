
node /dns(-\d+)?/ {
  class { 'dtg::minimal': dns_server => true, }

  # unbound is part of the minimal config
  # We just need to allow access through the firewall
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
  munin::gatherer::async_node { 'dns-0': }
}
