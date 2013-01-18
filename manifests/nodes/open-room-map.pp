node "open-room-map.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  class {'apache': }
  class {'dtg::apache::raven': server_description => 'Open Room Map'} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'open-room-map':
    source => 'puppet:///modules/dtg/apache/open-room-map.conf',
  }

    $openroommapversion="1.0.2"
    class {'dtg::tomcat': version => '7'} ->
      file {'/usr/local/share/openroommap-servlet':
      ensure => directory
    } ->
      wget::authfetch { "download":
      source => "\"http://dtg-maven.cl.cam.ac.uk/service/local/artifact/maven/redirect?r=releases&g=uk.ac.cam.cl.dtg&a=open-room-map&v=${openroommapversion}&e=war\"",
      destination => "/usr/local/share/openroommap-servlet/openroommap-${openroommapversion}.war",
      user => "dtg",
      password => "PetliujyowzaddOn"
    } ->
      file{"/var/lib/tomcat7/webapps/openroommap.war":
      ensure => link,
      target => "/usr/local/share/openroommap-servlet/openroommap-${openroommapversion}.war"
    }

  class {'dtg::firewall::publichttp':}

  class { 'postgresql::server': 
      config_hash => { 
        'ip_mask_deny_postgres_user' => '0.0.0.0/0', 
        'ip_mask_allow_all_users' => '127.0.0.1/32', 
        'listen_addresses' => '*', 
        'ipv4acls' => ['hostssl all all 127.0.0.1/32 md5']
      }
    } ->
    postgresql::db{'openroommap':
      user => "orm",
      password => "openroommap",
      charset => "UTF-8",
      grant => "ALL"
    } ->
    postgresql::database_user{'ormreader':
	password_hash => postgresql_password('ormreader', 'ormreader')
    } ->
    postgresql::database_grant{'ormreader':
        privilege => "select",
	db => "openroommap",
	role => "ormreader"
    }	
    
  # python-scipy is used by the machineroom site in /var/www/research/dtg/openroommap/machineroom
  # libdbd-pg-perli is used by the inventory site in /var/www/research/dtg/openroommap/inventory
  # libmath-polygon-perl is used by the rooms site /var/www/research/dtg/openroommap/rooms/
  $openroommappackages = ['python-scipy','libdbd-pg-perl', 'libmath-polygon-perl']
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
  file {'/etc/apache2/conf/':
    ensure => directory,
    require => Class['apache'],
  }
  file {'/etc/apache2/conf/group-raven':
    ensure => link,
    target => '/home/ravencron/group-raven',
    require => Class['dtg::ravencron::client'],
  }
  
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
  file {'/home/jenkins/.ssh/authorized_keys':
    ensure => file,
    mode => '0644',
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
  }

}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'open-room-map':
    parents    => '',
    address    => 'open-room-map.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'open-room-map': }
}
