node 'gitlab.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'gitlab':
    parents    => '',
    address    => 'gitlab.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'gitlab': }
}
