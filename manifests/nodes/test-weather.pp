node 'test-weather.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::git_wiki' 
}
# We don't actually mind if test-puppet goes down and we might take it down
# deliberately and not want emails triggered
#if ( $::fqdn == $::nagios_machine_fqdn ) {
#  nagios::monitor { 'test-puppet':
#    parents    => '',
#    address    => 'test-puppet.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers'],
#  }
#}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'test-weather': }
}
