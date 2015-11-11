$weather_ips = dnsLookup('weather.dtg.cl.cam.ac.uk')
$weather_ip = $weather_ips[0]

node 'weather.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class {'dtg::firewall::publichttp':}

  # Give weather-adm admin on these machines
  group { 'weather-adm': ensure => present }
  sudoers::allowed_command{ 'weather-adm':
    command => 'ALL',
    group => 'weather-adm',
    run_as => 'ALL',
    require_password => false,
    comment => 'Allow members of weather-adm group root on weather boxes',
  }

  # Mount nas01 in order to ship backups there.
  file {'/mnt/nas01':
    ensure => directory,
    owner  => 'weather',
  } ->
  package {'autofs':
    ensure => present,
  } ->
  file {'/etc/auto.nas01':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'nas01	nas01.dtg.cl.cam.ac.uk:/data/weather',
  } ->
  file_line {'mount nas01':
    line => '/mnt	/etc/auto.nas01',
    path => '/etc/auto.master',
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
