if ( $::fqdn =~ /(\w+-)?isaac-live/ ) {
  file { ['/usr/share/isaac/', '/usr/share/isaac/.ssh']:
    ensure => 'directory',
    owner  => 'isaac',
    group  => 'root',
    mode   => '0644',
  }

  file {'/usr/share/isaac/.ssh/authorized_keys':
    ensure => file,
    owner  => 'isaac',
    group  => 'isaac',
    mode   => '0600',
  }
  ->
  dtg::backup::serversetup{'Mongodb backup':
    backup_directory   => '/local/data/rutherford/database-backup/mongodb',
    script_destination => '/usr/share/isaac/mongodb-backup',
    user               => 'isaac',
    home               => '/usr/share/isaac/',
  }
  ->
  dtg::backup::serversetup{'Postgresql backup':
    backup_directory   => '/local/data/rutherford/database-backup/postgresql',
    script_destination => '/usr/share/isaac/postgres-backup',
    user               => 'isaac',
    home               => '/usr/share/isaac/',
  }
}

if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'isaac_physics_db':
    user    => 'isaac',
    host    => 'isaac-live.dtg.cl.cam.ac.uk',
    require => Class['dtg::backup::host'],
  }
}

if ( $::monitor ) {
  nagios::monitor { 'isaac-live':
    parents    => 'nas04',
    address    => 'isaac-live.dtg.cl.cam.ac.uk',
    hostgroups => ['ssh-servers' , 'http-servers'],
  }
  munin::gatherer::configure_node { 'isaac-live': }

  nagios::monitor { 'isaac-physics':
    parents    => ['isaac-live', 'balancer', 'cdn'],
    address    => 'isaacphysics.org',
    hostgroups => ['https-servers'],
  }
}
