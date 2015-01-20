# Monitor CL infrastructure so that we know when it is down
if ( $::monitor ) {
  nagios::monitor { 'se18-r8-sw1':
    parents    => '',
    address    => 'se18-r8-sw1.net.cl.cam.ac.uk',
    hostgroups => [],
  }
}
