node 'jenkins-master.dtg.cl.cam.ac.uk' {
  include minimal
}
if ( $::fqdn == $::nagios_server ) {
  nagios_monitor { 'jenkins-master':
    parents    => '',
    address    => 'jenkins-master.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'httpd-servers' ],
  }
}
if ( $::fqdn == $::munin_server ) {
  munin::gatherer::configure_node { 'jenkins-master': }
}
