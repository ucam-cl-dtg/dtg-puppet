node /acr31-containers(-\d+)?|containers(-\d+)?/ {
  include 'dtg::minimal'

  file{'/local/data/docker':
    ensure => directory,
    owner  => 'root'
  }
  ->
  class { 'docker':
    tcp_bind                    => 'tcp://127.0.0.1:2375',
    socket_bind                 => 'unix:///var/run/docker.sock',
    root_dir                    => '/local/data/docker',
    use_upstream_package_source => false,
    package_name                => 'docker.io',
    service_name                => 'docker.io',
    docker_command              => 'docker.io'
  }
  ->
  exec {'add-www-data-to-docker-group':
    unless  => "/bin/grep -q '^docker:\\S*www-data' /etc/group",
    command => '/usr/sbin/usermod -aG docker www-data',
  }
  ->
  file {'/etc/default/docker.io':
    source => '/etc/default/docker'
  }
  ->
  docker::image { 'ubuntu':
    image_tag => '14.04'
  }
    
  class {'dtg::containers::apt_java': stage => 'repos' }
  class {'dtg::firewall::publichttps':} ->
  class {'dtg::firewall::portforward': src=>'443',dest=>'8443',private=>false}

  $packages = ['oracle-java8-installer','libapr1','mongodb']

  $tomcat_version = '8.0.12'
  $tomcat_directory = "/opt/apache-tomcat-${tomcat_version}"

  $certificate_file = "/etc/ssl/${::hostname}.selfsigned.crt"
  $privatekey_file = "/etc/ssl/private/${::hostname}.selfsigned.key"

  $tomcat_server_conf = "${tomcat_directory}/conf/server.xml"
  
  package{$packages:
    ensure => installed,
  }
  ->
  wget::fetch{'wget-fetch-tomcat8':
    source      => "http://www.eu.apache.org/dist/tomcat/tomcat-8/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz",
    destination => "/opt/apache-tomcat-${tomcat_version}.tar.gz"
  }
  ->
  exec {'untar-tomcat8':
    command => "tar zxf /opt/apache-tomcat-${tomcat_version}.tar.gz && chown -R www-data /opt/apache-tomcat-${tomcat_version}",
    cwd     => '/opt',
    onlyif  => "test ! -d /opt/apache-tomcat-${tomcat_version}"
  }
  ->
  file {["${tomcat_directory}/webapps/docs",
         "${tomcat_directory}/webapps/ROOT",
         "${tomcat_directory}/webapps/examples",
         "${tomcat_directory}/webapps/host-manager",
         "${tomcat_directory}/webapps/manager"]:
           ensure => 'absent',
           force  => true
  }
  ->
  file {"${tomcat_directory}/logs":
    mode => '0777'
  }
  ->
  file {'/etc/init.d/tomcat8':
    content => template('dtg/tomcat/tomcat8-initd.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755'
  }
  ->
  exec {'generate-temporary-key':
    command => "/usr/bin/openssl req -new -x509 -days 999 -nodes -out ${certificate_file} -keyout ${privatekey_file} -batch",
    unless  => "test -e ${certificate_file}"
  }
  ->
  file {$privatekey_file:
    owner => 'www-data',
    mode  => '0500'
  }
  ->
  file {'/etc/ssl/private':
    owner => 'www-data',
    mode  => '0500'
  }
  ->
  file {$tomcat_server_conf:
    content => template('dtg/tomcat/httpsserverconf.erb'),
    owner   => 'root',
    mode    => '0755'
  }
  ->
  wget::fetch{'download libtcnative':
    source      => 'http://cz.archive.ubuntu.com/ubuntu/pool/universe/t/tomcat-native/libtcnative-1_1.1.31-1_amd64.deb',
    destination => '/opt/libtcnative-1_1.1.31-1_amd64.deb'
  }
  ->
  file {'/usr/lib/libapr-1.so.0':
    ensure => 'link',
    target => '/usr/lib/x86_64-linux-gnu/libapr-1.so.0'
  }
  ->
  file {'/usr/lib/libtcnative-1.so':
    ensure => 'link',
    target => '/usr/lib/x86_64-linux-gnu/libtcnative-1.so'
  }
  ->
  exec {'install-libtcnative':
    command => '/usr/bin/dpkg -i /opt/libtcnative-1_1.1.31-1_amd64.deb',
    unless  => 'dpkg -s libtcnative-1 | grep ^Status.*installed'
  }
  ->
  exec {'tomcat8-on-boot':
    command => '/usr/sbin/update-rc.d tomcat8 defaults'
  }
  ->
  exec {'start-tomcat':
    command => '/etc/init.d/tomcat8 start',
    unless  => '/usr/bin/pgrep -f tomcat'
  }
}

#if ( $::monitor ) {
#  nagios::monitor { 'containers-1':
#    parents    => 'nas04',
#    address    => 'containers-1.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' , 'https-servers' ],
#  }
#  munin::gatherer::async_node { 'containers-1': }
#}

class dtg::containers::apt_java {
  apt::ppa { 'ppa:webupd8team/java': }
  ->
  exec {'set-licence-selected':
    command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
  }
  ->
  exec {'set-licence-seen':
    command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections'
  }
}
