node /jenkins-master(-\d+)?/ {
  include 'dtg::minimal'
  class { 'dtg::jenkins': }
}


if ( $::monitor ) {
  nagios::monitor { 'jenkins-master':
    parents    => 'nas04',
    address    => 'jenkins-master.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::async_node { 'jenkins-master': }
}
