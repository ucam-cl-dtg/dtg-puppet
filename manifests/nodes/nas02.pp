if ( $::monitor ) {
  nagios::monitor { 'nas02':
    parents    => 'se18-r8-sw1',
    address    => 'nas02.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers', 'nfs-servers' ],
  }
}
