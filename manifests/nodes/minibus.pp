if ( $::monitor ) {
  nagios::monitor { 'minibus':
    parents    => 'nas04',
    address    => 'minibus.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'minibus': }
}
