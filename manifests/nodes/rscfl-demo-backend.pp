if ( $::monitor ) {
  nagios::monitor { 'rscfl-demo-backend':
    parents    => 'nas04',
    address    => 'rscfl-demo-backend.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'rscfl-demo-backend': }
}
