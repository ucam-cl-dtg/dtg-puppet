node 'jenkins-master.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class { 'dtg::jenkins': }
  class { 'sonar': version => '3.2'}
}


if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'jenkins-master':
    parents    => '',
    address    => 'jenkins-master.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'jenkins-master': }
}
