node /isaac-1/ {
  class { 'dtg::minimal': managefirewall => false }

  class {'dtg::isaac':}

  class {'dtg::firewall':
    interfacefile => '/etc/network/interfaces.d/eth0.cfg',
  }
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
      ensure  => present,
      path    => '/local/data/database-backup/isaac-database-backup.log',
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
  ->
  cron { 'osticket-cron':
    command => 'docker exec isaac-tickets php /var/www/html/api/cron.php',
    user    => root,
    minute  => '*/1'
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
