node /isaac-[23]|isaac-demo/ {
  class { 'dtg::minimal':
    managefirewall        => false,
    send_rsyslog          => false,
    exim_local_interfaces => '0.0.0.0',
    exim_smarthost        => 'ppsw.cam.ac.uk',
    exim_relay_nets       => '10.0.0.0/9',
    user_whitelist        => ['acr31','drt24','arb33','jps79','ipd21','sac92','af599','mlt47','du220','rjm49'],
  }

  User<|title == jps79 |> { groups +>[ 'adm' ] }
  User<|title == ipd21 |> { groups +>[ 'adm' ] }
  
  class {'dtg::isaac':}

  class {'dtg::firewall':
    ssh_source    => $::local_subnet,
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

  # Jenkins user
  group {'jenkins':
    ensure => present,
  }
  ->
  user {'jenkins':
    ensure   => present,
    gid      => 'jenkins',
    groups   => ['isaac'],
    password => '*',
  }
  ->
  file {'/home/jenkins':
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0755',
  }
  ->
  file {'/home/jenkins/.ssh/':
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0755',
  }
  ->
  file {'/home/jenkins/.ssh/authorized_keys':
    ensure  => file,
    mode    => '0644',
    content => 'no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="cd /local/src/isaac-api && git pull && cd /local/src/isaac-app && git pull && ./build-in-docker.sh master master && ./compose dev master up -d",from="128.232.21.0" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
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
  file { '/local/data/isaac-backup.public.pem':
      mode   => '0755',
      owner  => isaac,
      group  => isaac,
      source => 'puppet:///modules/dtg/isaac/isaac-backup.public.pem'
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

  # Home directory of isaac user:
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

  # ssh-notify Script:
  file { '/local/data/ssh-notify.sh':
      mode   => '0755',
      owner  => isaac,
      group  => isaac,
      source => 'puppet:///modules/dtg/isaac/ssh-notify.sh'
  }
  ->
  file_line { 'ssh-notify-pam.d':
    line => 'session optional pam_exec.so seteuid /local/data/ssh-notify.sh',
    path => '/etc/pam.d/sshd',
  }

  # Update sysctl.conf to disable IPV6 and support ElasticSearch.
  file_line { 'disable_ipv6_1':
    line => 'net.ipv6.conf.all.disable_ipv6 = 1',
    path => '/etc/sysctl.conf',
  }
  ->
  file_line { 'disable_ipv6_2':
    line => 'net.ipv6.conf.default.disable_ipv6 = 1',
    path => '/etc/sysctl.conf',
  }
  ->
  file_line { 'disable_ipv6_3':
    line => 'net.ipv6.conf.lo.disable_ipv6 = 1',
    path => '/etc/sysctl.conf',
  }
  ->
  file_line { 'max_map_count':
    line => 'vm.max_map_count = 262144',
    path => '/etc/sysctl.conf',
  }

}

## Config only for main live server, not standby.
if ( $::fqdn =~ /(\w+-)?isaac-3/ ) {

  # Tickets database backup:
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
    command     => 'docker exec isaac-tickets php /var/www/html/api/cron.php',
    # Not postmaster, because that goes into tickets...
    environment => 'MAILTO=osticket-cron@isaacphysics.org',
    user        => root,
    minute      => '*/1'
  }
  ->
  cron {'isaac-osticket-backup':
    command => '/local/data/isaac-osticket-database-backup.sh >> /local/data/database-backup/isaac-osticket-backup.log',
    user    => root,
    hour    => 0,
    minute  => 0
  }

  # Postgres Vacuum log and cron job:
  file { '/local/data/isaac-docker-database-vacuum.sh':
      mode   => '0755',
      owner  => isaac,
      group  => isaac,
      source => 'puppet:///modules/dtg/isaac/isaac-docker-database-vacuum.sh'
  }
  ->
  file { '/var/log/isaac/isaac-vacuum.log':
      ensure  => present,
      path    => '/var/log/isaac/isaac-vacuum.log',
      replace => false,
      mode    => '0664',
      owner   => isaac,
      group   => isaac,
      content => '# Postgres Vacuum Log'
  }
  ->
  cron {'isaac-vacuum-db':
    command => '/local/data/isaac-docker-database-vacuum.sh >> /var/log/isaac/isaac-vacuum.log',
    user    => root,
    hour    => 3,
    minute  => 33,
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

# Configure nagios and munin:
if ( $::monitor ) {

  # Configure munin for both machines:
  munin::gatherer::async_node { 'isaac-2': }
  munin::gatherer::async_node { 'isaac-3': }

  # Configure nagios to monitor live site:
  nagios::monitor { 'isaac-physics':
    parents    => '',
    address    => 'isaacphysics.org',
    hostgroups => ['https-servers'],
  }
  # Configure nagios to monitor editor:
  nagios::monitor { 'isaac-editor-external':
    parents                     => '',
    address                     => 'editor.isaacphysics.org',
    hostgroups                  => [ 'http-servers', 'https-servers' ],
    include_standard_hostgroups => false,
  }
  # Configure nagios to monitor tickets:
  nagios::monitor { 'isaac-tickets-external':
    parents                     =>  '',
    address                     => 'tickets.isaacphysics.org',
    hostgroups                  => [ 'http-servers', 'https-servers' ],
    include_standard_hostgroups => false,
  }
}
