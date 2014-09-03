node /(\w+-)?isaac-live/ {
  # dbbackup user
  user {'isaac':
    ensure => present,
    shell => '/bin/bash',
    home => "/usr/share/isaac"
  }
  ->
  file { ["/usr/share/isaac/", "/usr/share/isaac/.ssh"]:
    ensure => "directory",
    owner  => "isaac",
    group  => "root",
    mode   => 644,
  }
  ->
  file {'/usr/share/isaac/.ssh/authorized_keys':
    ensure => file,
    owner  => 'isaac',
    group  => 'isaac',
    mode   => '0600',
  }
  ->
  dtg::backup::serversetup{'Mongodb backup':
    backup_directory   => '/local/data/rutherford/database-backup',
    script_destination => '/usr/share/isaac/backup',
    user               => 'isaac',
    home               => '/usr/share/isaac/',
  }
}

if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'isaac_physics_db':
    user => 'isaac',
    host => 'isaac-live.dtg.cl.cam.ac.uk',
    require => Class["dtg::backup::host"],
  }
}

if ( $::monitor ) {
  nagios::monitor { 'isaac-live':
    parents    => 'nas04',
    address    => 'isaac-live.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' , 'http-servers' ],
  }
  munin::gatherer::configure_node { 'isaac-live': }

  nagios::monitor { 'isaac-physics':
    parents    => ['isaac-live', 'balancer'],
    address    => 'isaacphysics.org',
    hostgroups => ['https-servers'],
  }
}
