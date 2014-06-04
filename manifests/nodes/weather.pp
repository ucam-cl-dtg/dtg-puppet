node 'weather.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of debian to point at
  class { 'dtg::minimal': manageapt => false, }
  class {'dtg::firewall::publichttp':}

  # Mount nas01 in order to ship backups there.
  file {'/mnt/nas01':
    ensure => directory,
    owner  => 'weather',
  } ->
  package {'autofs':
    ensure => present,
  } ->
  file {'/etc/auto.nas01':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => 'a=r',
    content => 'nas01	nas01.dtg.cl.cam.ac.uk:/data/weather',
  } ->
  file_line {'mount nas01':
    line => '/mnt/nas01	/etc/auto.nas01',
    path => '/etc/auto.master',
  }
}

if ( $::monitor ) {
  nagios::monitor { 'weather':
    parents    => 'nas04',
    address    => 'weather.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'weather': }
}
