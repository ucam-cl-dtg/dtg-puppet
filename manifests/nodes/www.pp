if ( $::monitor ) {
  nagios::monitor { 'www':
    parents    => '',
    address    => 'dtg-www.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
}
