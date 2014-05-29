if ( $::monitor ) {
  nagios::monitor { 'learn':
    parents    => 'nas04',
    address    => 'learn.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'learn': }
}
