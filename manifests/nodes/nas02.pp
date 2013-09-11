if ( $::monitor ) {
  nagios::monitor { 'nas02':
    parents    => '',
    address    => 'nas02.cl.cam.ac.uk',
    hostgroups => [ ],
  }
}
