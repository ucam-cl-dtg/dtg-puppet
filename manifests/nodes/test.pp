node 'test-puppet.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
}
if ( $::monitor ) {
  munin::gatherer::configure_node { 'test-puppet': }
}
