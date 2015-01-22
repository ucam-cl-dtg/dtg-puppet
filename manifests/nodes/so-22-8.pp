node 'so-22-8.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class { 'dtg::firewall::publichttp': }
  ->
  class { 'dtg::firewall::80to8080': }
}

if ( $::monitor ) {
  munin::gatherer::configure_node { 'so-22-8': }
}
