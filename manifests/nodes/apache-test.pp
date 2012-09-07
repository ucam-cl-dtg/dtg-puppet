node 'apache-test.dtg.cl.cam.ac.uk' {
  include minimal
  class {'apache': }
  class { 'dtg::apache::raven': server_description => "James apache raven",}
  class {'dtg::firewall::publichttp':}
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios_monitor { 'apache-test':
    parents    => '',
    address    => 'apache-test.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'apache-test': }
}
