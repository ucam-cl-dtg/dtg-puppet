node 'code.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'apache': }
  class {'dtg::apache::raven': server_description => 'DTG Code Server'}
  class {'dtg::maven': }
  class {'dtg::firewall::publichttp':}
  class {'dtg::git':}
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'code':
    parents    => '',
    address    => 'code.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  nagios::monitor { 'maven':
    parents    => 'code',
    address    => 'dtg-maven.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'code': }
}
