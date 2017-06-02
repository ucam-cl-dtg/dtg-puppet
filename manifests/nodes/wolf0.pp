node /wolf(\d+)?/ {
  include 'dtg::minimal'

  class { 'dtg::rscfl': }
  if !$::is_virtual {
    # This is already included elsewhere for VMs
    class { 'dtg::autologin': }
  }
}

if ( $::monitor ) {
  munin::gatherer::async_node { 'wolf1': }
  munin::gatherer::async_node { 'wolf2': }

  nagios::monitor { 'wolf2-bmc':
    parents    => '',
    address    => 'wolf2-bmc.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'bmcs' ],
  }
}
