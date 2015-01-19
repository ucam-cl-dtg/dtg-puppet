if ( $::monitor ) {
  nagios::monitor { 'nas02':
    parents    => '',
    address    => 'nas02.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
