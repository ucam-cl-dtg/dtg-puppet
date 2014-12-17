if ( $::monitor ) {
  nagios::monitor { 'www':
    parents    => '',
    address    => 'inuit.dtg.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
}
