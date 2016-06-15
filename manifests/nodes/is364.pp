
node 'is364-scratch.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  dtg::add_user { 'is364':
    real_name => 'Ian Sheret',
    groups    => ['adm'],
    keys      => ['Ian Sheret <is364@cam.ac.uk>'],
    uid       => 3179,
  }
}
#if ( $::monitor ) {
#  nagios::monitor { 'is364-scratch':
#    parents    => 'nas04',
#    address    => 'is364-scratch.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' ],
#  }
#  munin::gatherer::async_node { 'is364': }
#}
