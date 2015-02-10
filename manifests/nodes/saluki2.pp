if ( $::monitor ) {
  nagios::monitor { 'saluki2':
    parents    => 'se18-r8-sw1',
    address    => 'saluki2.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'saluki2': }
}
