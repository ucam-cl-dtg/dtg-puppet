node "open-room-map.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  class {'apache': }
  class {'dtg::apache::raven': server_description => 'Open Room Map'} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'open-room-map':
    source => 'puppet:///modules/dtg/apache/open-room-map.conf',
  }
  class {'dtg::tomcat': version => '7'}
  class {'dtg::firewall::publichttp':}
  $openroommappackages = ['postgresql-9.1']
  package{$openroommappackages:
    ensure => installed,
  }
  file {'/var/www/research/':
    ensure => directory,
    require => Class['apache'],
  }
  file {'/var/www/research/dtg/':
    ensure => directory,
  }
  file {'/var/www/research/dtg/openroommap':
    ensure => directory,
  }
  class {'dtg::ravencron::client':}
  group {'jenkins': ensure => present,}
  group {'www-data': ensure => present,}
  user {'jenkins':
    ensure => present,
    gid => 'jenkins',
    groups => ['www-data'],
  }
  file {'/home/jenkins':
    ensure => directory,
    owner => 'jenkins',
    group => 'jenkins',
    mode  => '0755',
  }
  file {'/home/jenkins/.ssh/':
    ensure => directory,
    owner => 'jenkins',
    group => 'jenkins',
    mode => '0755',
  }
  file {'/home/jenkins/.ssh/autorized_keys':
    ensure => file,
    mode => '0644',
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
  }

}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'HOSTNAME':
    parents    => '',
    address    => 'open-room-map.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'open-room-map': }
}
