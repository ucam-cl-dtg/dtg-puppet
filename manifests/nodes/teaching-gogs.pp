node /^teaching-gogs/ {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttps':}
  ->
  class {'dtg::firewall::publichttp':}

  # used by the app.ini template
  $gogs_domain = 'gogs.cl.cam.ac.uk'
  $gogs_root_url = 'http://gogs.cl.cam.ac.uk/gogs'
  
  class {'apache::ubuntu': }
  ->
  class {'dtg::apache::raven':
    server_description => 'Gogs'
  }
  ->
  apache::module {'proxy':}
  ->
  apache::module {'proxy_http':}
  ->
  exec {'generate-AAHeaderKey':
    command => '/bin/bash -c "echo -n \"AAHeaderKey \"; openssl rand -hex 24" > /etc/apache2/AAHeaderKey.conf',
    creates => '/etc/apache2/AAHeaderKey.conf'
  }
  ->
  file {'/etc/apache2/AAHeaderKey.conf':
    owner => 'root',
    group => 'root',
    mode  => '0600'
  }
  ->
  exec {'generate-AACookieKey':
    command => '/bin/bash -c "echo -n \"AACookieKey \"; openssl rand -hex 24" > /etc/apache2/AACookieKey.conf',
    creates => '/etc/apache2/AACookieKey.conf'
  }
  ->
  file {'/etc/apache2/AACookieKey.conf':
    owner => 'root',
    group => 'root',
    mode  => '0600'
  }
  ->
  apache::site {'gogs':
    source => 'puppet:///modules/dtg/apache/gogs.conf',
  }

  class { 'postgresql::globals':
    version      => '9.5',
    encoding     => 'UTF-8',
    locale       => "'en_GB.UTF8'",
    datadir      => '/local/data/postgres',
    needs_initdb => true
  }
  ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '127.0.0.1/32',
    listen_addresses           => '*',
    ipv4acls                   => ['hostssl all all 127.0.0.1/32 md5'],
  }
  ->
  postgresql::server::db{'gogs':
    user     => 'gogs',
    password => 'gogs',
    grant    => 'ALL',
  }

  user {'git':
    ensure => 'present',
    shell  => '/bin/bash',
    home   => '/local/data/git-home',
  }
  file {'/local/data/git-home':
    ensure => 'directory',
    owner  => 'git',
  }
  ->
  dtg::nexus::fetch{'download-gogs':
    artifact_name         => 'gogs',
    artifact_version      => '1.0.0-SNAPSHOT',
    artifact_type         => 'zip',
    destination_directory => '/local/data/gogs',
    action                => 'unzip',
  }
  ->
  exec { 'chown-/local/data/git-home':
    command     => 'chown -R git.git /local/data/git-home',
  }
  ->
  exec { 'chown-/local/data/gogs':
    command     => 'chown -R git.git /local/data/gogs',
  }
  ->
  file {'/etc/systemd/system/gogs.service':
    source => 'puppet:///modules/dtg/gogs/gogs.service'
  }
  ->
  file {'/local/data/gogs/gogs/custom':
    ensure => 'directory'
  }
  ->
  file {'/local/data/gogs/gogs/custom/conf':
    ensure => 'directory'
  }
  ->
  file {'/local/data/gogs/gogs/custom/conf/app.ini':
    owner   => 'git',
    group   => 'git',
    mode    => '0600',
    content => template('dtg/gogs/app.ini.erb')
  }
  ->
  exec {'app-ini-set-raven-key':
    command => '/bin/bash -c "HEADER_KEY=`/usr/bin/cut -d \" \" -f2 /etc/apache2/AAHeaderKey.conf `; /bin/sed -i \"s/RAVEN_HEADER_KEY.*/RAVEN_HEADER_KEY = \${HEADER_KEY}/\" /local/data/gogs/gogs/custom/conf/app.ini"' # lint:ignore:single_quote_string_with_variables
  }
  ->
  exec {'app-ini-set-gogs-key':
    command => '/bin/bash -c "SECRET_KEY=`cat /etc/apache2/AACookieKey.conf | /usr/bin/sha1sum | /usr/bin/cut -d \" \" -f 1`; /bin/sed -i \"s/SECRET_KEY.*/SECRET_KEY = \${SECRET_KEY}/\" /local/data/gogs/gogs/custom/conf/app.ini"' # lint:ignore:single_quote_string_with_variables
  }
  ->
  file {'/local/data/gogs-repositories':
    ensure => 'directory',
    owner  => 'git',
    group  => 'git',
  }
  ->
  file {'/local/data/gogs-log':
    ensure => 'directory',
    owner  => 'git'
  }
  ->
  exec {'systemctl-daemon-reload':
    command => '/bin/systemctl daemon-reload'
  }
  ->
  exec {'enable-gogs-service':
    command => '/bin/systemctl enable gogs.service'
  }
  ->
  exec {'restart-gogs-service':
    command => '/bin/systemctl restart gogs.service'
  }

  package{'tomcat8':
    ensure => "installed",
  }
  
}
