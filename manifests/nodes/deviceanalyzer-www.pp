# DeviceAnalyzer running in a LX domain on SmartOS
# This node hosts the webserver for receiving uploads as well as providing the main website for the project
# WARNING. Deviceanalyzer needs an SSL certificate and htpasswd configuration in /etc/nginx/sec. This is not stored in puppet. 
node 'deviceanalyzer-www' {
  class { 'dtg::minimal': manageentropy => false, managefirewall => false }

  class {'dtg::deviceanalyzer':}

  # Packages which should be installed
  $packagelist = ['openjdk-8-jdk', 'jetty8', 'nginx']
  package {
    $packagelist:
      ensure => installed
  }

  # set up nginx and jetty config
  file {'/etc/nginx/sites-enabled/default':
    ensure => absent,
  }
  file {'/etc/nginx/sites-enabled/deviceanalyzer.nginx.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/deviceanalyzer.nginx.conf',
  }
  file {'/etc/default/jetty8':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/jetty8',
  }
  file {'/etc/init.d/xmlsocketserver':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/deviceanalyzer/xmlsocketserver.initd',
  }

  # ensure webapps directory is writeable by the non-standard 'www-deviceanalyzer' user
  file { '/var/lib/jetty8/webapps':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'adm',
    mode   => '0755',
  }
  file { '/var/lib/jetty8':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'adm',
    mode   => '0755',
  }
  file { '/var/log/jetty8':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'adm',
    mode   => '0755',
  }

  file {'/nas2':
    ensure => link,
    target => '/deviceanalyzer/data',
  }
  file {'/nas4':
    ensure => link,
    target => '/deviceanalyzer/export',
  }
  file {'/nas4-index':
    ensure => link,
    target => '/deviceanalyzer/picky-index',
  }
  file {'/nas4-snapshot':
    ensure => link,
    target => '/deviceanalyzer/export',
  }
  
}

