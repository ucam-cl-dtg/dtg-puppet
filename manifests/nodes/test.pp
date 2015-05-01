node 'test-puppet.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == sa497 |> { groups +>[ 'adm' ]}
}
if ( $::monitor ) {
  munin::gatherer::configure_node { 'test-puppet': }
}
