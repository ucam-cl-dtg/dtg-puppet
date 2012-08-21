node 'test-puppet.dtg.cl.cam.ac.uk' {
  include minimal
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios_monitor { 'test-puppet':
    parents    => '',
    address    => 'test-puppet.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'test-puppet': }
}
