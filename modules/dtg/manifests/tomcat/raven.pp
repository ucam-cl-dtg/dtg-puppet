class dtg::tomcat::raven inherits dtg::tomcat {
  class {'dtg::tomcat::raven::repo': stage => 'repos'}
  file { "/etc/${::tomcat}/raven_pubkey.crt":
    source  => 'puppet:///modules/dtg/raven/pubkey2.crt',
    mode    => '0644',
    owner   => 'root',
    group   => $::tomcat,
    require => Package[$::tomcat],
  }
  file { "/etc/${::tomcat}/server.xml":
    source  => "puppet:///modules/dtg/raven/${::tomcat}_server.xml",
    mode    => '0644',
    owner   => 'root',
    group   => $::tomcat,
    require => Package[$::tomcat]
  }
  package{'libucamwebauth-java':
    ensure  => installed,
    require => Apt::Ppa['ppa:ucam-cl-dtg/ucam'],
  }
  package{ 'libucamwebauth-tomcat-java':
    ensure  => installed,
    require => Package['libucamwebauth-java'],
  }
  $tomcatlib = "/usr/share/${::tomcat}/lib/"
  file {"${tomcatlib}/webauth.jar":
    ensure  => link,
    target  => '/usr/share/java/ucamwebauth.jar',
    require => Package['libucamwebauth-java'],
  }
  file {"${tomcatlib}/webauth-tomcat.jar":
    ensure  => link,
    target  => '/usr/share/java/ucamwebauth-tomcat.jar',
    require => Package['libucamwebauth-tomcat-java'],
  }
  package{'libcommons-logging-java':
    ensure => installed,
  }
  file {"${tomcatlib}/commons-logging.jar":
    ensure  => link,
    target  => '/usr/share/java/commons-logging.jar',
    require => Package['libcommons-logging-java'],
  }
  package{'libcommons-codec-java':
    ensure => installed,
  }
  file {"${tomcatlib}/commons-codec.jar":
    ensure  => link,
    target  => '/usr/share/java/commons-codec.jar',
    require => Package['libcommons-codec-java'],
  }
}

class dtg::tomcat::raven::repo { # lint:ignore:autoloader_layout repo class
  apt::ppa {'ppa:ucam-cl-dtg/ucam': }
}
