node /wolf(\d+)?/ {
  include 'dtg::minimal'

  class { 'dtg::rscfl': }
}

if ( $::monitor ) {
  munin::gatherer::configure_node { 'wolf0': }
}
if ( $::monitor ) {
  munin::gatherer::configure_node { 'wolf1': }
}
if ( $::monitor ) {
  munin::gatherer::configure_node { 'wolf2': }
  nagios::monitor { 'wolf2-bmc':
    parents    => '',
    address    => 'wolf2-bmc.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}
