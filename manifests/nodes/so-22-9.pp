node 'so-22-9.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'distcc':
    listen_ip_range => $dtg_subnet,
    listen_on_ip    => '',
  }

  class { 'dtg::firewall::publichttp': }

}

if ( $::monitor ) {
  munin::gatherer::configure_node { 'so-22-9': }
}
