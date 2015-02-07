node 'so-22-9.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class { 'dtg::firewall::publichttp': }

  firewall { 'Accept 8080':
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
  }
}

if ( $::monitor ) {
  munin::gatherer::configure_node { 'so-22-9': }
}