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

  # Retrieve the weather server git repository:
  vcsrepo {'/srv/weather/weather-srv-2':
    ensure => latest,
    provider => git,
    # TODO: move the repository to the ucam-cl-dtg organization
    source => 'https://github.com/cillian64/dtg-weather-2.git',
    revision => 'master',
    user => 'weather',
    require => User['weather'],
    notify => [ File['upstart-script'],
                Service['weather-service'],
              ],
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
  
  # Start up the weather service
  service {'weather-service':
    name => 'weather',
    ensure => running,
    enable => true,
    require => [ Exec['create-venv'],
                 File['upstart-script'],
                 Vcsrepo['/srv/weather/weather-srv-2'],
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
    source => 'file:///srv/weather/weather-srv-2/weather.nginx.conf',
    notify => Service['nginx'],
    require => Vcsrepo['/srv/weather/weather-srv-2'],
  }
  
  # Start up nginx:
  service {"nginx":
    enable => true,
    ensure => running,
    require => [ File['nginx-disable-default'],
                 File['nginx-conf'],
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
