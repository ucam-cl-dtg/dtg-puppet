class dtg::tomcat ($version = '8'){
#TODO set a sane heap space in /etc/default/tomcat$version or performance will be terrible
  $tomcat = "tomcat${version}"
  package { $tomcat:
    ensure => installed,
  }
  service { $tomcat:
    ensure  => running,
    require => Package[$tomcat]
  }
  munin::node::plugin {'tomcat_access':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/tomcat/tomcat_access',
  }
}
