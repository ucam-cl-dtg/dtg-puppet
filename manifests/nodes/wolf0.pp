node 'wolf0.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class { 'dtg::rscfl': }
}

if ( $::monitor ) {
  munin::gatherer::configure_node { 'wolf0': }
}
