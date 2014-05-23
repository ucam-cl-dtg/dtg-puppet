if ( $::monitor ) {
  nagios::monitor { 'learn':
    parents    => '',
    address    => 'svr-acr31-minibus.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'minibus': }
}
