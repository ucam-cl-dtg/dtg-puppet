node 'test-puppet.dtg.cl.cam.ac.uk' {
  include minimal
}
if ( $::fqdn == $::nagios_server ) {
  nagios_monitor { 'test-puppet':
    parents    => '',
    address    => 'test-puppet.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}
if ( $::fqdn == $::munin_server ) {
  munin::gatherer::configure_node { 'test-puppet': }
}
