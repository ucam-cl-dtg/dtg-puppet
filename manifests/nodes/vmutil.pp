node 'vmutil.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'vmutil':
    hosts         => 'husky0.dtg.cl.cam.ac.uk husky1.dtg.cl.cam.ac.uk husky2.dtg.cl.cam.ac.uk',
    password_file => '/local/data/vmutil.password',
    xe_path       => '/local/data/xe'
  }
}
if ($::monitor) {

  nagios::monitor {'vmutil':
    parents    => 'nas04',
    address    => 'vmutil.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'vmutil': }
}
