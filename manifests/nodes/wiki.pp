node 'wiki.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::git_wiki' 
}
if ( $::monitor ) {
  nagios::monitor { 'wiki':
    parents    => 'nas04',
    address    => 'wiki.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'https-servers' ],
  }
  munin::gatherer::configure_node { 'wiki': }
}
