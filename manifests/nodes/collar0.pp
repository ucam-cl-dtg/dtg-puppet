if ( $::monitor ) {
  nagios::monitor { 'collar0':
    parents    => '',
    address    => 'collar0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
}
