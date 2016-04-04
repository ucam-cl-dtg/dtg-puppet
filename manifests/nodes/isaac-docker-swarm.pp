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


}