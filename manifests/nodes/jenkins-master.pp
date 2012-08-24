node 'jenkins-master.dtg.cl.cam.ac.uk' {
  include minimal
  class { 'dtg::jenkins': }
  class { 'dtg::firewall::publichttp': }
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios_monitor { 'jenkins-master':
    parents    => '',
    address    => 'jenkins-master.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'jenkins-master': }
}
