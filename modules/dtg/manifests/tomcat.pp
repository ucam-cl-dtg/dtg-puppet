class dtg::tomcat ($version = '6'){
  $tomcat = "tomcat$version"
  package { $tomcat:
    ensure => installed,
  }
  service { $tomcat:
    ensure => running,
    require => Package[$tomcat]
  }
}
class dtg::tomcat::raven inherits dtg::tomcat {
  file { "/etc/$tomcat/raven_pubkey.crt":
    source => 'puppet:///modules/dtg/raven/pubkey2.crt',
    mode   => 644,
    owner  => 'root',
    group  => $tomcat,
    require => Package[$tomcat],
  }
  file { "/etc/$tomcat/server.xml":
    source => "puppet:///modules/dtg/raven/${tomcat}_server.xml",
    mode   => 644,
    owner  => 'root',
    group  => $tomcat,
    require => Package[$tomcat]
  }
  # TODO(drt24) Install the required jars
}
