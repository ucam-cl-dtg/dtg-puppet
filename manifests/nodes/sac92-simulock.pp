# VM for rsa33's part 2 project - sac92 is supervisor.
node 'sac92-simulock.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  dtg::add_user { 'rsa33':
    real_name => 'Richard Allitt',
    groups    => [ 'adm' ],
    keys      => '',
    uid       => 3253,
  } ->
  ssh_authorized_key {'rsa33_key_windows':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDPBjD5pcqSSszBGhWnjt5Na8+JBZQWcE0z0qF4BIaynlCUy1ATe6fopo3lA0+zOuUXMbRb/uh6aUkD3KTvSRLZ9IVNmlgeDCuXNQRiznsERaYVX7Vq/ixvU5YoCmhE7CvYNm4SXsHEO8HS1+IhBXwNg8XHWRNxdO0RxvheC1obGYJwQpN062jCCOPJ2HqUJoKJ1jcnIIzELS1+6yl2bQvslSJ3CxGuTypXOCCLELAUA2Hzl9xr2IShXjf8qsWFxQdv948NM/SxYcwy+9W8TOTzI26RKdXGrcetdUBV9YNXkTSUD35qJgdQEiVn0Z0nwYm33JW45PhiXkZsrdUseUDT',
    user   => 'rsa33',
    type   => 'ssh-rsa',
  } ->
  ssh_authorized_key {'rsa33_key_ubuntu':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDx92pV9kH5JlPT/1KDUJojGUWgdgxZgQ6vBhmyEYpkrHg8cttz2d2Y4rFt/T6Fw2khvyFtSu4/xPKFzFrnnQ8E3Rd7PGot4u5hNGHMo5W9MTp+3aV0913s9cu824+FdnXJvuGewX/DEDbcsAwAqBg5n+8yjLUs0Szm5OccQTNJWMXY9lunITmZevIxABgEfv6aJZEoIbqnVOg+BsoFMEqD4Wzf5esSztE+rzIH3jFPg1FybWLsmupbt/FMFUtyQg3Q4YMjhZ4yR2M+ty8KDrdDPaim5OnU5sqFK/GVY6K9sqbaOcxEihUvBtviWY4I5j8LrGcehFX5Pj5CbYXQcol7',
    user   => 'rsa33',
    type   => 'ssh-rsa',
  } ->
  ssh_authorized_key {'rsa33_key_easter':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCyGGHeNkbAjo1a5YmTOUuqIDqG6ZQ8/bb0PBFNjOybVnPUY+sRBw8eT7iqfiLRBxPp14B//OOW+jYX9oXszV7S/cMGg0om9ipMrhVTqIvWQ2NASA2XW6J8EzTeFSOJ+OMa/TKZE8nbz6UznV5+8K+PH/m0Xfi/cdNvKFnkCfq4t+A6a+flbS3fisjSE0fgArx1BLraqPo3uKNH+aoeTpFKaa37amQZ3i9tYmEpCOvsXCo7WoqJ5f4jezUf1wIHtxINEIYHp4OVcxo6jA8q6PzGzCrs+myqHdPsJNeJOnCVK1vM2EHM7nGg7Oe4IaRH2bodH9LR1JlkCZxTbuxGP+wV',
    user   => 'rsa33',
    type   => 'ssh-rsa',
  }  

  $packages = ['maven2','openjdk-7-jdk']
  package{$packages:
    ensure => installed
  }

  class {'dtg::firewall::publichttp':}
}
if ( $::monitor ) {
  nagios::monitor { 'sac92-simulock':
    parents    => 'nas04',
    address    => 'sac92-simulock.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'sac92-simulock': }
}
