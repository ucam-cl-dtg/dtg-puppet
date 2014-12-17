if ( $::monitor ) {
  nagios::monitor { 'inuit':
    parents    => '',
    address    => 'inuit.dtg.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
}
