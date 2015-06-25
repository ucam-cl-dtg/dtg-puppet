$weather2_ips = dnsLookup('weather2.dtg.cl.cam.ac.uk')
$weather2_ip = $weather2_ips[0]

node 'weather2.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class {'dtg::firewall::publichttp':}  # Allow port 80 incoming

  # Make dwt27 have admin on this machine
  User<|title == 'dwt27' |> { groups +>[ 'adm' ]}

  # Install our interfaces file with weather2's static IP:
  file {'/etc/network/interfaces':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/dtg/weather2/interfaces',
  }

  # Install all our packages
  $packagelist = ['nginx', 'python3', 'python3-dev', 'python3-pip',
                  'python-virtualenv', 'python3-virtualenv',]
  package {$packagelist:
        ensure => installed,
  } -> # Ensure nginx starts on boot
  service {"nginx":
    enable => true,
    ensure => running,
  }

  # Setup our weather webapp user
  group {'weather':
    ensure => present,
  } ->
  user {'weather':
    ensure => present,
    shell => '/bin/bash',
    home => '/srv/weather',
    password => '*',
    managehome => true,
    gid => 'weather',
  }

  # Retrieve the weather server git repository:
  vcsrepo {'/srv/weather/weather-srv-2':
    ensure => latest,
    provider => git,
    # TODO: move the repository to the ucam-cl-dtg organization
    source => 'https://github.com/cillian64/dtg-weather-2.git',
    revision => 'master',
    user => 'weather',
    require => User['weather'],
    notify => Service['weather-service'],  # Restart service upon changes
  }
  
  # Setup the venv and stuff if required:
  exec {'create-venv':
    creates => '/srv/weather/venv',
    command => '/srv/weather/weather-srv-2/create_venv.sh',
    cwd => '/srv/weather/',
    user => 'weather',
    group => 'weather',
    require => Vcsrepo['/srv/weather/weather-srv-2'],
  }
  
  # Install the upstart script
  file {'upstart-script':
    path => '/etc/init/weather.conf',
    ensure => file,
    owner => 'root',
    group => 'root',
    source => 'file:///srv/weather/weather-srv-2/upstart_script.conf',
    require => Vcsrepo['/srv/weather/weather-srv-2'],
  }
  
  # Start up the weather service!
  service {'weather-service':
    name => 'weather',
    ensure => running,
    enable => true,
    require => Exec['create-venv'],
    require => File['upstart-script'],
    require => Vcsrepo['/srv/weather/weather-srv-2'],
  }
}

# Disable monitoring until things are more stable:
#if ( $::monitor ) {
#  nagios::monitor { 'weather2':
#    parents    => 'nas04',
#    address    => 'weather2.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers', 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'weather2': }
#}
