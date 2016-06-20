node 'rscfl-demo.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class { 'dtg::firewall::publichttp': }
  ->
  class { 'dtg::firewall::80to8080': }
}

if ( $::monitor ) {
  munin::gatherer::async_node { 'rscfl-demo': }
}
