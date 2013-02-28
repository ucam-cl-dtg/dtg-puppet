node 'wiki.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::git_wiki' 
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'wiki':
    parents    => '',
    address    => 'wiki.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],#TODO(drt24) monitor https-servers
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'wiki': }
}
