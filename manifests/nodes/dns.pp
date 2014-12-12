
node /dns(-\d+)?/ {
  include 'dtg::minimal'
  class { "unbound":
    interface => ["::0","0.0.0.0"],
    access    => [ $::local_subnet, "::1"],
  }
  unbound::forward { '.':
    address => [
      '128.232.1.1', # CL
      '128.232.1.2',
      '128.232.1.3',
      '8.8.8.8', # Google
      '8.8.4.4',
      '208.67.222.222', # OpenDNS
      '208.67.220.220'
      ]
  }
}
if ( $::monitor ) {
  nagios::monitor { 'dns-0':
    parents    => 'nas04',
    address    => 'dns-0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'dns-0': }
}
