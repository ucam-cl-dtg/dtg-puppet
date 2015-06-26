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
                  'python-virtualenv', 'python3-virtualenv',
                  'libpq5', 'libpq-dev', 'postgresql-client']
  package {$packagelist:
        ensure => installed,
        before => [ Service['nginx'],
                    Exec['create-venv'],
                  ]
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
    purge_ssh_keys => true,
  }

  # Setup the production weather server
  file {'/srv/weather/production':
    ensure => directory,
    owner => 'weather',
    group => 'weather',
    require => User['weather'],
  } ->  # Checkout git repo and keep up to date
  vcsrepo {'/srv/weather/production/weather-srv-2':
    ensure => latest,
    provider => git,
    source => 'https://github.com/cillian64/dtg-weather-2.git',
    revision => 'master',
    user => 'weather',
    notify => [ File['upstart-script-production'],
                Service['weather-service-production'],
              ],
  } ->  # Create venv
  exec {'create-venv-production':
    creates => '/srv/weather/production/venv',
    command => '/srv/weather/production/weather-srv-2/create_venv.sh',
    cwd => '/srv/weather/production',
    user => 'weather',
    group => 'weather',
  }  # Install service
  file {'upstart-script-production':
    path => '/etc/init/weather.conf',
    ensure => file,
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/dtg/weather2/upstart_script.conf',
    require => Vcsrepo['/srv/weather/production/weather-srv-2'],
  }
  
  # Setup the development weather server
  file {'/srv/weather/development':
    ensure => directory,
    owner => 'weather',
    group => 'weather',
    require => User['weather'],
  } ->  # Checkout git repo and keep up to date
  vcsrepo {'/srv/weather/development/weather-srv-2':
    require => Vcsrepo['/srv/weather/weather-srv-2'],
    ensure => latest,
    provider => git,
    source => 'https://github.com/cillian64/dtg-weather-2.git',
    revision => 'development',
    user => 'weather',
    notify => [ File['upstart-script-development'],
                Service['weather-service-development'],
              ],
  } ->  # Create venv
  exec {'create-venv-development':
    creates => '/srv/weather/development/venv',
    command => '/srv/weather/development/weather-srv-2/create_venv.sh',
    cwd => '/srv/weather/development',
    user => 'weather',
    group => 'weather',
  }  # Install service
  file {'upstart-script-development':
    path => '/etc/init/weather-dev.conf',
    ensure => file,
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/dtg/weather2/upstart_script-dev.conf',
    require => Vcsrepo['/srv/weather/development/weather-srv-2'],
  }
  
  # Start both weather services
  service {'weather-service-production':
    name => 'weather',
    ensure => running,
    enable => true,
    require => [ Exec['create-venv-production'],
                 File['upstart-script-production'],
                 Vcsrepo['/srv/weather/production/weather-srv-2'],
               ],
  }
  service {'weather-service-development':
    name => 'weather-dev',
    ensure => running,
    enable => true,
    require => [ Exec['create-venv-development'],
                 File['upstart-script-development'],
                 Vcsrepo['/srv/weather/development/weather-srv-2'],
               ],
  }

  # Configure nginx:
  file {'nginx-disable-default':
    path => '/etc/nginx/sites-enabled/default',
    ensure => absent,
  }
  file {'nginx-conf':
    path => '/etc/nginx/sites-enabled/weather.nginx.conf',
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/dtg/weather2/weather.nginx.conf',
    notify => Service['nginx'],
  }
  file {'nginx-conf-dev':
    path => '/etc/nginx/sites-enabled/weather-dev.nginx.conf',
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/dtg/weather2/weather-dev.nginx.conf',
    notify => Service['nginx'],
  }
  
  # Start up nginx:
  service {"nginx":
    enable => true,
    ensure => running,
    require => [ File['nginx-disable-default'],
                 File['nginx-conf'],
                 File['nginx-conf-dev'],
               ],
  }

  # Setup the user for the postgres ssh tunnel
  group {'postgres-ssh-tunnel':
    ensure => present,
  } ->
  user {'postgres-ssh-tunnel':
    ensure => present,
    shell => '/usr/sbin/nologin',
    home => '/home/postgres-ssh-tunnel',
    password => '*',
    managehome => true,
    gid => 'postgres-ssh-tunnel',
    purge_ssh_keys => true,
  } ->
  ssh_authorized_key {'postgres-ssh-tunnel-key':
    ensure => present,
    type => 'ssh-rsa',
    user => 'postgres-ssh-tunnel',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC1op9dVlbQoguAtT0ciVsgEnI1bcGpYkB1KbuuR1MaStB0PbwgbWbNXtHCW5fLQNUab5r1C2C7RKGGGMG4GeotfsyJcvyrn1kgyZXA0qDQH3G4/gNIXx0V0GuZrMt0hvXsauV1sUQyEePFQJZ9j9VMR9jh7QVM5SAAsBKiufhUmsVwqCrjqPujJ2dtYAhygDlJw4m9sP1Axoqyka82hFotvcq45AgOUZ2f6JAKIbXLpq+osfknXHeBIerFPlZqCR38G73VvkaS6Gz3W0qXq+3d5nhqOdicqzKclb5lMcJCIEAE/C45hRItl4Co+Vcrr7IztNdtdxLhYIGivNVQk91t',
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
