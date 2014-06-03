node 'weather.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of debian to point at
  class { 'dtg::minimal': manageapt => false, }
  class {'dtg::firewall::publichttp':}
}

if ( $::monitor ) {
  nagios::monitor { 'weather':
    parents    => 'nas04',
    address    => 'weather.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'weather': }
}
