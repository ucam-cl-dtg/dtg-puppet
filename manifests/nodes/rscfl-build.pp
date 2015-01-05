if ( $::monitor ) {
  nagios::monitor { 'rscfl-build':
    parents    => 'nas04',
    address    => 'rscfl-build.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'rscfl-build': }
}
