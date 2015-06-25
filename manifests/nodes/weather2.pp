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
                  'python3-virtualenv',]
  package {$packagelist:
        ensure => installed,
  }
  # Ensure nginx starts on boot
  service {"nginx":
    enable => true,
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
    require => Group['weather'],
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
