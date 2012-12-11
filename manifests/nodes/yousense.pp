node 'yousense.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  dtg::add_user { 'ml421':
    real_name => 'Mattias Linnap',
    groups    => [ 'adm' ],
    keys      => 'Mattias Linnap <mattias@linnap.com>',
  }

#  apt:ppa {'ppa:pitti/postgresql': }

  package {
    ['nginx', 'uwsgi', 'uwsgi-plugin-python', 'python-pip', 'python-dev',
     'tree', 'git', 'htop', 'rabbitmq-server', 'inotify-tools']:
      ensure => installed
  }

}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'yousense':
    parents    => '',
    address    => 'yousense.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'yousense': }
}
