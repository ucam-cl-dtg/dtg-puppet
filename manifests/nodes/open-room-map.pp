node /open-room-map(-\d+)?/ {
  include 'dtg::minimal'
  class {'apache::ubuntu': } ->
  class {'dtg::apache::raven': server_description => 'Open Room Map'} ->
  apache::module {'authz_groupfile':} ->
  apache::module {'cgi':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'open-room-map':
    source => 'puppet:///modules/dtg/apache/open-room-map.conf',
  }
  
  $servlet_version = "1.0.5"
  $webtree_version = "1.0.16"

  schedule {'daily':
    period => daily,
    repeat => 1,
  }

  $tomcat_version = '8'
  # Install the openroommap servlet code.  This requires tomcat
  class {'dtg::tomcat': version => $tomcat_version}
  ->
  dtg::nexus::fetch{"download-servlet":
    artifact_name => "open-room-map",
    artifact_version => $servlet_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/openroommap-servlet",
    symlink => "/var/lib/tomcat{$tomcat_version}/webapps/openroommap.war",
  }
  
  # Install the openroommap static web tree.  This is hosted by apache
  file {"/var/www/research/":
    ensure => directory,
    require => Class['apache'],
  }
  ->
  file {'/var/www/research/dtg/':
    ensure => directory
  }
  ->
  dtg::nexus::fetch{"download-webtree":
    artifact_name => "open-room-map-webtree",
    artifact_version => $webtree_version,
    artifact_type => "zip",
    destination_directory => "/usr/local/share/openroommap-webtree",
    action => "unzip",
    symlink => "/var/www/research/dtg/openroommap",
  }
  ->
  dtg::nexus::fetch{"download-tiles":
    artifact_name => "open-room-map-tiles",
    artifact_version => "1.0.0-SNAPSHOT",
    artifact_type => "zip",
    artifact_classifier => "live",
    destination_directory => "/usr/local/share/openroommap-tiles",
    action => "unzip",
    symlink => "/var/www/research/dtg/openroommap/static/tile",
    always_refresh => true,
  }
  
  class {'dtg::firewall::publichttp':}

  class { 'postgresql::globals':
    version => '9.4',
  }
  ->
  class { 'postgresql::server': 
    ip_mask_deny_postgres_user => '0.0.0.0/0', 
    ip_mask_allow_all_users => '127.0.0.1/32', 
    listen_addresses => '*', 
    ipv4acls => ['hostssl all all 127.0.0.1/32 md5']
  }
  ->
  postgresql::server::db{'openroommap':
    user => "orm",
    password => "openroommap",
    encoding => "UTF-8",
    grant => "ALL"
  }
  ->
  postgresql::server::role{'ormreader':
    password_hash => postgresql_password('ormreader', 'ormreader')
  }
  ->
  dtg::nexus::fetch{"download-ormbackup":
    artifact_name => "open-room-map-backup",
    artifact_version => "1.0.0-SNAPSHOT",
    artifact_type => "zip",
    artifact_classifier => "live",
    destination_directory => "/usr/local/share/openroommap-backup",
    action => "unzip"
  }
  ->
  exec{"restore-openroommap-backup":
    command => "psql -U orm -d openroommap -h localhost -f /usr/local/share/openroommap-backup/open-room-map-backup-1.0.0-SNAPSHOT/backup.sql",
    environment => "PGPASSWORD=openroommap",
    path => "/usr/bin:/bin",
    unless => 'psql -U orm -h localhost -d openroommap -t -c "select count(*) from room_table"'
  }  
  ->
  postgresql::server::db{'machineroom':
    user => "machineroom",
    password => "machineroom",
    encoding => "UTF-8",
    grant => "ALL"
  }
  ->
  dtg::nexus::fetch{"download-machinebackup":
    artifact_name => "machine-power-backup",
    artifact_version => "1.0.0-SNAPSHOT",
    artifact_type => "zip",
    artifact_classifier => "live",
    destination_directory => "/usr/local/share/machine-power-backup",
    action => "unzip"
  }
  ->
  exec{"restore-machinepower-backup":
    command => "psql -U machineroom -d machineroom -h localhost -f /usr/local/share/machine-power-backup/machine-power-backup-1.0.0-SNAPSHOT/backup.sql",
    environment => "PGPASSWORD=machineroom",
    path => "/usr/bin:/bin",
    unless => 'psql -U machineroom -h localhost -d machineroom -t -c "select count(*) from categories"'
  }  

  # python-scipy, python-jinja2 is used by the machineroom site in /var/www/research/dtg/openroommap/machineroom
  # libdbd-pg-perli is used by the inventory site in /var/www/research/dtg/openroommap/inventory
  # libmath-polygon-perl is used by the rooms site /var/www/research/dtg/openroommap/rooms/
  $openroommappackages = ['python-scipy','python-jinja2' ,'libdbd-pg-perl', 'libmath-polygon-perl','python-psycopg2']
  package{$openroommappackages:
    ensure => installed,
  }

  file {'/etc/apache2/conf/':
    ensure => directory,
    require => Class['apache'],
  }
  ->
  wget::fetch { "wget-fetch-ravengroup":
    source => "http://sysdata.cl.cam.ac.uk/www-conf/group-raven",
    destination => "/etc/apache2/conf/group-raven",
    redownload => true,
    schedule => daily
  } 

  group {'jenkins': 
    ensure => present,
  } 
  ->
  user {'jenkins':
    ensure => present,
    gid => 'jenkins',
    password => '*',
  }
  ->
  file {'/home/jenkins':
    ensure => directory,
    owner => 'jenkins',
    group => 'jenkins',
    mode  => '0755',
  }
  ->
  file {'/home/jenkins/.ssh/':
    ensure => directory,
    owner => 'jenkins',
    group => 'jenkins',
    mode => '0755',
  }
  ->
  file {'/home/jenkins/.ssh/authorized_keys':
    ensure => file,
    mode => '0644',
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
  }

  cron { update-tiles-snapshot:
    command => "cd /etc/puppet && puppet apply --verbose --modulepath modules manifests/site.pp 2>&1 >/var/log/puppet/update-log",
    user    => root,
    hour    => 4,
    minute  => 0
  }
  
}
if ( $::monitor ) {
  nagios::monitor { 'open-room-map':
    parents    => 'nas04',
    address    => 'open-room-map.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'open-room-map': }
}
