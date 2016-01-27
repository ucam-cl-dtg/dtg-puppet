node 'cccc-openvz.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  virt { 'test-1':
    ensure      => 'running',
    os_template => 'ubuntu-15.10',
    virt_type   => 'openvz',
    autoboot    => 'true'
  }
}
/* Not yet production
if ( $::monitor ) {
  nagios::monitor { 'HOSTNAME':
    parents    => '',
    address    => 'HOSTNAME.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'HOSTNAME': }
}
*/
