node 'jenkins-master.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class { 'dtg::jenkins': }
  class { 'sonar': version => '3.2'}
}


if ( $::monitor ) {
  nagios::monitor { 'jenkins-master':
    parents    => 'nas04',
    address    => 'jenkins-master.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'jenkins-master': }
}
