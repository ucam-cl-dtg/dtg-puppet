$weather_ips = dnsLookup('weather.dtg.cl.cam.ac.uk')
$weather_ip = $weather_ips[0]

node 'weather.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class {'dtg::firewall::publichttp':}
# Gives the weather-adm group admin on these machines.
  class {'dtg::weather': }

  # ACR - removed these mounts. backups are now done by the backup servers ssh'ing into the vm and pulling the data through the ssh connection
  # Mount nas01 and africa01 in order to ship backups there.
  # First, install autofs:
#  package {'autofs':
#   ensure => present,
#  } ->
  # Now, ensure auto.master includes auto.mnt at /mnt:
#  file_line {'mount nas01':
#    line => '/mnt	/etc/auto.mnt',
#    path => '/etc/auto.master',
#  } ->
  # Add our auto.mnt including nas01 and africa01:
#  file {'/etc/auto.mnt':
#    ensure  => file,
#    owner   => 'root',
#    group   => 'root',
#    mode    => 'a=r',
#    content => '
#nas01       nas01.dtg.cl.cam.ac.uk:/data/weather
#africa01    africa01.dtg.cl.cam.ac.uk:/data-pool0/weather
#'
#  }

  group {"weather":
    ensure => present,
    gid => 200
  }
  ->
  user { "weather" :
    ensure => present,
    comment => "Weather service user",
    home => "/home/weather",
    shell => "/bin/bash",
    groups => ["www-data","man","dtg","dtg-web"],
    uid => 501,
    gid => 200,
    password => "*",
  }
  ->
  file {'/home/weather/.ssh/authorized_keys':
    ensure => file,
    owner  => 'weather',
    group  => 'weather',
    mode   => '0600',
  }
  ->
  dtg::backup::serversetup_script {'weather backup':
    content => "nice pg_dump -O weather | bzip2",
    script_destination => "/home/weather/backup.sh",
    user => "weather",
    home => "/home/weather/",
  }
  
  # Temporarily disable service restarts so that
  # postgres restarts stop killing everything.
  file {'/etc/default/postupdate-service-restart':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'ACTION=false',
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

if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'weather_database':
    user    => 'weather',
    host    => 'weather.dtg.cl.cam.ac.uk',
    require => Class['dtg::backup::host'],
    weekday => '*',
  }
}
