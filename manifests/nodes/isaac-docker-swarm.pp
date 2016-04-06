node /isaac-\d+/ {
  include 'dtg::minimal'

  class {'dtg::isaac':}

  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  
  # User to own DB Backups
  user {'isaac':
    ensure => present,
    shell  => '/bin/bash',
    home   => '/usr/share/isaac'
  }

  # Directories to hold backups
  file { '/local/data/database-backup':
    ensure => 'directory',
    owner  => 'isaac',
    group  => 'isaac',
    mode   => '0755',
  }
  ->
  file { '/local/data/database-backup/backups':
    ensure => 'directory',
    owner  => 'isaac',
    group  => 'isaac',
    mode   => '0755',
  }
  ->
  file { '/local/data/database-backup/latest':
    ensure => 'directory',
    owner  => 'isaac',
    group  => 'isaac',
    mode   => '0755',
  }
  ->
  file { '/local/data/isaac-docker-database-backup.sh':
      mode   => '0755',
      owner  => isaac,
      group  => isaac,
      source => 'puppet:///modules/dtg/isaac/isaac-docker-database-backup.sh'
  }
  ->
  file { '/local/data/database-backup/isaac-database-backup.log':
      path    => '/local/data/database-backup/isaac-database-backup.log',
      ensure  => present,
      replace => false,
      mode    => '0664',
      owner   => isaac,
      group   => isaac,
      content => '# Database backup log files'
  }
  ->
  cron {'isaac-backup-database':
    command => '/local/data/isaac-docker-database-backup.sh >> /local/data/database-backup/isaac-database-backup.log',
    user    => root,
    hour    => 0,
    minute  => 0
  }

  # Home directory of isaac user.

  file { ['/usr/share/isaac/', '/usr/share/isaac/.ssh']:
    ensure => 'directory',
    owner  => 'isaac',
    group  => 'root',
    mode   => '0644',
  }
  ->
  file {'/usr/share/isaac/.ssh/authorized_keys':
    ensure => file,
    owner  => 'isaac',
    group  => 'isaac',
    mode   => '0600',
  }
  ->
  dtg::backup::serversetup{'Live DB Backup':
    backup_directory   => '/local/data/database-backup/latest',
    script_destination => '/usr/share/isaac/database-backup',
    user               => 'isaac',
    home               => '/usr/share/isaac/',
  }
}

# Configure backup server to pull things from here.

if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'isaac_physics_docker_db':
    user    => 'isaac',
    group   => 'isaac',
    host    => 'isaac-1.dtg.cl.cam.ac.uk',
    weekday => '*',
    require => Class['dtg::backup::host'],
  }
}
