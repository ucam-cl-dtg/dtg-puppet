node 'wiki.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::git_wiki' 
}
if ( $::monitor ) {
  nagios::monitor { 'wiki':
    parents    => '',
    address    => 'wiki.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],#TODO(drt24) monitor https-servers
  }
  munin::gatherer::configure_node { 'wiki': }
}
