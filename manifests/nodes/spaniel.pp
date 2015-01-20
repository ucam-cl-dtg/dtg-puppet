node 'spaniel.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of raspbian to point at
  class { 'dtg::minimal': manageapt => false, }

  $packages = ['xmonad', 'x11-xserver-utils', 'unclutter']
  package{$packages:
    ensure => installed
  }
}

if ( $::monitor ) {
  nagios::monitor { 'spaniel':
    parents    => '',
    address    => 'spaniel.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'spaniel': }
}
