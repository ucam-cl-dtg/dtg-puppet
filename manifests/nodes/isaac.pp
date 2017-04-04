node /isaac-[23]/ {
  class { 'dtg::minimal':
    managefirewall => false,
    exim_local_interfaces => '0.0.0.0',
    exim_smarthost => 'ppsw.cam.ac.uk',
    exim_relay_nets => '10.0.0.0/9',
  }

  class {'dtg::isaac':}

  class {'dtg::firewall':
    interfacefile => '/etc/network/interfaces.d/eth0.cfg',
  }
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  class {'dtg::firewall::isaacsmtp':}
  class {'dtg::firewall::vrrp':}
  
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
  dtg::backup::serversetup{'Isaac Backup':
    backup_directory   => '/local/data/database-backup/latest',
    script_destination => '/usr/share/isaac/database-backup',
    user               => 'isaac',
    home               => '/usr/share/isaac/',
  }
}

## Config only for main live server, not standby.

if ( $::fqdn =~ /(\w+-)?isaac-3/ ) {
  file { '/local/data/isaac-osticket-database-backup.sh':
      mode   => '0755',
      owner  => isaac,
      group  => isaac,
      source => 'puppet:///modules/dtg/isaac/isaac-osticket-database-backup.sh'
  }
  ->
  file { '/local/data/database-backup/isaac-osticket-backup.log':
      ensure  => present,
      path    => '/local/data/database-backup/isaac-osticket-backup.log',
      replace => false,
      mode    => '0664',
      owner   => isaac,
      group   => isaac,
      content => '# OSTicket backup log files'
  }
  ->
  cron { 'osticket-cron':
    command => 'docker exec isaac-tickets php /var/www/html/api/cron.php',
    # Not postmaster, because that goes into tickets...
    environment => 'MAILTO=osticket-cron@isaacphysics.org',
    user    => root,
    minute  => '*/1'
  }
  ->
  cron {'isaac-osticket-backup':
    command => '/local/data/isaac-osticket-database-backup.sh >> /local/data/database-backup/isaac-osticket-backup.log',
    user    => root,
    hour    => 0,
    minute  => 0
  }
}

# Configure backup server to pull things from the VIRTUAL Isaac IP.

if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'isaac_physics_live_db':
    user    => 'isaac',
    group   => 'isaac',
    host    => '128.232.21.250',
    weekday => '*',
    require => Class['dtg::backup::host'],
  }
}
