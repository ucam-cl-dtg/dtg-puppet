node 'africa01.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'nfs::server'  

  class {'dtg::zfs': }

}

if ( $::monitor ) {
  nagios::monitor { 'africa01':
    parents    => '',
    address    => 'africa01.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'africa01': }
}

