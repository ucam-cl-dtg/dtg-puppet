node 'spaniel.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of raspbian to point at
  class { 'dtg::minimal': manageapt => false, }

  $packages = ['xmonad', 'x11-xserver-utils', 'unclutter']
  package{$packages:
    ensure => installed
  }
}
