node 'code.dtg.cl.cam.ac.uk' {
  include minimal
  class {'apache': }
  class {'dtg::apache::raven': }
  class {'dtg::maven': }
  class {'dtg::firewall::publichttp':}
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios_monitor { 'code':
    parents    => '',
    address    => 'code.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  nagios_monitor { 'maven':
    parents    => 'code',
    address    => 'dtg-maven.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'code': }
}
