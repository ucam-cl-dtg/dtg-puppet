
node /dns(-\d+)?/ {
  include 'dtg::minimal'
  class { 'unbound':
    interface    => ['::0','0.0.0.0'],
    access       => [ $::local_subnet, '::1'],
    tcp_upstream => true,
  }
  unbound::forward { '.':
    address => [
      '131.111.8.42', #UIS
      '131.111.12.20', #UIS
      '128.232.1.2', #CL
      '128.232.1.3', #CL
      '8.8.8.8', # Google
      '8.8.4.4',
      '208.67.222.222', # OpenDNS
      '208.67.220.220',
      '128.232.1.1', # CL
      ]
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
