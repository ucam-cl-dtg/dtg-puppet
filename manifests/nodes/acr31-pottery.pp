node /^acr31-pottery/ {
  include 'dtg::minimal'

  class {'dtg::pottery::aptsources': stage => 'repos' }
  
  file{'/local/data/docker':
    ensure => directory,
    owner  => 'root'
  }
  ->
  package{'docker-ce':
    ensure => installed,
  }
  ->
  class { 'docker':
    tcp_bind                    => 'tcp://127.0.0.1:2375',
    socket_bind                 => 'unix:///var/run/docker.sock',
    root_dir                    => '/local/data/docker',
    use_upstream_package_source => false,
    manage_package              => false,
  }
  ->
  exec {'add-www-data-to-docker-group':
    unless  => "/bin/grep -q '^docker:\\S*www-data' /etc/group",
    command => '/usr/sbin/usermod -aG docker www-data',
  }
  ->
  docker::image { 'ubuntu':
    image_tag => '16.04'
  }
    
  class {'dtg::firewall::publichttps':}
  ->
  class {'dtg::firewall::publichttp':}

  $packages = ['openjdk-8-jdk','libapr1','tomcat8','golang-go',]

  package{$packages:
    ensure => installed,
  }

  # used by the app.ini template
  $gogs_domain = 'acr31-pottery.dtg.cl.cam.ac.uk'
  $gogs_root_url = 'http://acr31-pottery.dtg.cl.cam.ac.uk/gogs/'
  
  class {'apache::ubuntu': }
  ->
  class {'dtg::apache::raven':
    server_description => 'Pottery'
  }
  ->
  apache::module {'proxy':}
  ->
  apache::module {'proxy_http':}
  ->
  apache::site {'pottery':
    source => 'puppet:///modules/dtg/apache/pottery.conf',
  }
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
  
  class { 'postgresql::globals':
    version  => '9.5',
    encoding => 'UTF-8',
    locale   => "'en_GB.UTF8'"
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
    home   => '/home/git',
  }
  ->
  dtg::nexus::fetch{'download-gogs':
    artifact_name         => 'gogs',
    artifact_version      => '1.0.0-SNAPSHOT',
    artifact_type         => 'zip',
    destination_directory => '/home/git',
    action                => 'unzip',
  }
  ->
  exec { 'chown-/home/git':
    command => 'chown -R git.git /home/git',
    refreshonly => true
  }
  ->
  file {'/etc/systemd/system/gogs.service':
    source => 'puppet:///modules/dtg/gogs/gogs.service'
  }
  ->
  file {'/home/git/gogs/custom':
    ensure => 'directory'
  }
  ->
  file {'/home/git/gogs/custom/conf':
    ensure => 'directory'
  }
  ->
  file {'/home/git/gogs/custom/conf/app.ini':
    owner => 'git',
    group => 'git',
    mode => '0600',
    content => template('dtg/gogs/app.ini.erb')
  }
  ->
  exec {'app-ini-set-raven-key':
    command => '/bin/bash -c "HEADER_KEY=`/usr/bin/cut -d \" \" -f2 /etc/apache2/AAHeaderKey.conf `; /bin/sed -i \"s/RAVEN_HEADER_KEY.*/RAVEN_HEADER_KEY = \${HEADER_KEY}/\" /home/git/gogs/custom/conf/app.ini"'
  }
  ->
  exec {'app-ini-set-gogs-key':
    command => '/bin/bash -c "SECRET_KEY=`cat /etc/apache2/AACookieKey.conf | /usr/bin/sha1sum | /usr/bin/cut -d \" \" -f 1`; /bin/sed -i \"s/SECRET_KEY.*/SECRET_KEY = \${SECRET_KEY}/\" /home/git/gogs/custom/conf/app.ini"'
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
}

class dtg::pottery::aptsources { # lint:ignore:autoloader_layout repo class
  apt::source{ 'docker':
    location => 'https://download.docker.com/linux/ubuntu',
    release  => 'xenial',
    repos    => 'stable',
    key      => {
      'id'     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
      'source' => 'https://download.docker.com/linux/ubuntu/gpg',
    }
  }
}
