define bayncore::setup() {

  exec { 'remount':
    command     => '/bin/mount -a',
    refreshonly => true,
  }

  package {['gfortran']:
    ensure => installed,
  }
  
  file {'/mnt/bayncore':
    ensure => directory,
  }
  ->
  file_line { 'mount nas04':
    ensure => present,
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/bayncore /mnt/bayncore nfs defaults 0 0',
    path   => '/etc/fstab',
    notify => Exec['remount'],
  }
  ->
  file_line { 'mount home':
    ensure => present,
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/bayncore/home /home nfs defaults 0 0',
    path   => '/etc/fstab',
    notify => Exec['remount'],
  }
}
