node 'rscfl-demo.dtg.cl.cam.ac.uk' {
  class { 'dtg::firewall::80to8080': }
}

if ( $::monitor ) {
  nagios::monitor { 'rscfl-demo':
    parents    => 'nas04',
    address    => 'rscfl-demo.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'rscfl-demo': }
}
