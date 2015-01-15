if ( $::monitor ) {
  nagios::monitor { 'rscfl-demo':
    parents    => 'nas04',
    address    => 'rscfl-demo.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'rscfl-demo': }
}
