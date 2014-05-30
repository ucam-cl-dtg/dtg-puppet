if ( $::monitor ) {
  nagios::monitor { 'weather':
    parents    => 'nas04',
    address    => 'weather.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'weather': }
}
