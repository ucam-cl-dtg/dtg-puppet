# DeviceAnalyzer running in a LX domain on SmartOS

node 'deviceanalyzer-lx' {
  class { 'dtg::minimal': manageentropy => false, }

  class {'dtg::deviceanalyzer':}

  # Packages which should be installed
  $packagelist = ['openjdk-7-jdk', 'jetty8', 'nginx', 'autofs']
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
  file {'/etc/network/interfaces':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/interfaces',
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

}

