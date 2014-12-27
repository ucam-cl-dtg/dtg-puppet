if ( $::monitor ) {
  nagios::monitor { 'collar1':
    parents    => '',
    address    => 'collar1.dtg.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
}
