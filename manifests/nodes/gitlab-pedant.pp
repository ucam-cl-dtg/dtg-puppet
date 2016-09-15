node 'gitlab-pedant.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'dtg::scm':}
  firewall { '030 accept on 5000':
    proto  => 'tcp',
    dport  => 5000,
    action => 'accept',
  }
}

if ( $::monitor ) {
  nagios::monitor { 'gitlab-pedant':
    parents    => 'nas04',
    address    => 'gitlab-pedant.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  munin::gatherer::async_node { 'gitlab-pedant': }
}
