/*Monitor CL infrastructure so that we know when it is down*/
if ( $::monitor ) {
  nagios::monitor { 'www.cl':
    parents    => '',
    address    => 'www.cl.cam.ac.uk',
    hostgroups => [ 'http-servers', 'https-servers' ],
  }
}
