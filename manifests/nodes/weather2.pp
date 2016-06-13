node /^weather2(-dev)?.dtg.cl.cam.ac.uk$/ {
  class { 'dtg::minimal': }
  # Give weather-adm admin on these machines:
  class { 'dtg::weather': }

  # Open weather2's firewall
  # weather2-dev keeps its closed firewall
  # Both keep their DTG VLAN puppy IP.
  if ( $::hostname == 'weather2' ) {
    class {'dtg::firewall::publichttp':}
  }

  # Install all our packages
  $packagelist = ['nginx', 'python3', 'python3-dev', 'python3-pip',
                  'python-virtualenv', 'python3-virtualenv',
                  'libpq5', 'libpq-dev', 'postgresql-client',
                  'libfreetype6-dev', 'libpng-dev', 'pkg-config',
                  'python3-matplotlib', 'libjpeg-dev']
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
    ensure         => present,
    shell          => '/bin/bash',
    home           => '/srv/weather',
    password       => '*',
    managehome     => true,
    gid            => 'weather',
    purge_ssh_keys => true,
  }

  # Setup the weather service
  # Checkout appropriate git branch and keep up to date
  $weather_repo_branch = $::hostname ? {
    'weather2'      => 'master',
    'weather2-dev'  => 'development',
  }
  vcsrepo {'/srv/weather/weather-srv':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/cillian64/dtg-weather-2.git',
    revision => $weather_repo_branch,
    user     => 'weather',
    notify   => [ File['systemd-script'], Service['weather-service'] ],
  } ->  # Create venv
  exec {'create-venv':
    creates => '/srv/weather/venv',
    command => '/srv/weather/weather-srv/create_venv.sh',
    cwd     => '/srv/weather/',
    user    => 'weather',
    group   => 'weather',
  }
  # Install service
  file {'systemd-script':
    ensure  => file,
    path    => '/etc/systemd/system/weather.service',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/dtg/weather2/systemd_job.service',
    require => Vcsrepo['/srv/weather/weather-srv'],
  }

  # Start the weather services
  service {'weather-service':
    ensure  => running,
    name    => 'weather',
    enable  => true,
    require =>  [ Exec['create-venv'],
                  File['systemd-script'],
                  Vcsrepo['/srv/weather/weather-srv'],
                ],
  }

  # Configure nginx:
  file {'nginx-disable-default':
    ensure  => absent,
    path    => '/etc/nginx/sites-enabled/default',
    require => Package['nginx'],
  }
  file {'nginx-conf':
    ensure  => file,
    path    => '/etc/nginx/sites-enabled/weather.nginx.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/dtg/weather2/weather.nginx.conf',
    notify  => Service['nginx'],
    require => Package['nginx'],
  }

  # Start up nginx:
  service {'nginx':
    ensure  => running,
    enable  => true,
    require => [
      File['nginx-disable-default'],
      File['nginx-conf'],
      Package['nginx'],
    ],
  }

  # Setup the user for the postgres ssh tunnel
  group {'postgres-ssh-tunnel':
    ensure => present,
  } ->
  user {'postgres-ssh-tunnel':
    ensure         => present,
    shell          => '/usr/sbin/nologin',
    home           => '/home/postgres-ssh-tunnel',
    password       => '*',
    managehome     => true,
    gid            => 'postgres-ssh-tunnel',
    purge_ssh_keys => true,
  } ->
  ssh_authorized_key {'postgres-ssh-tunnel-key':
    ensure => present,
    type   => 'ssh-rsa',
    user   => 'postgres-ssh-tunnel',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC1op9dVlbQoguAtT0ciVsgEnI1bcGpYkB1KbuuR1MaStB0PbwgbWbNXtHCW5fLQNUab5r1C2C7RKGGGMG4GeotfsyJcvyrn1kgyZXA0qDQH3G4/gNIXx0V0GuZrMt0hvXsauV1sUQyEePFQJZ9j9VMR9jh7QVM5SAAsBKiufhUmsVwqCrjqPujJ2dtYAhygDlJw4m9sP1Axoqyka82hFotvcq45AgOUZ2f6JAKIbXLpq+osfknXHeBIerFPlZqCR38G73VvkaS6Gz3W0qXq+3d5nhqOdicqzKclb5lMcJCIEAE/C45hRItl4Co+Vcrr7IztNdtdxLhYIGivNVQk91t',
  }
}

# Disable monitoring until things are more stable:
#if ( $::monitor ) {
#  # Note: do not monitor weather2-dev
#  nagios::monitor { 'weather2':
#    parents    => 'nas04',
#    address    => 'weather2.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers', 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'weather2': }
#}
