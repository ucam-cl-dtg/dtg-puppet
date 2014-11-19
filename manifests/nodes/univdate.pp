node /univdate(-\d+)?/ {
  include 'dtg::minimal'

  class {'apache': }
  ->
  apache::module {'proxy':}
  ->
  apache::module {'proxy_http':}
  ->
  apache::site {'univdate':
    source => 'puppet:///modules/dtg/apache/univdate.conf',
  }
  
  $servlet_version = "1.0.0-SNAPSHOT"

  $tomcat_version = '8'
  class {'dtg::tomcat': version => $tomcat_version}
  ->
  dtg::nexus::fetch{"download-servlet":
    artifact_name => "univdate",
    artifact_version => $servlet_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/univdate-servlet",
    symlink => "/var/lib/tomcat${tomcat_version}/webapps/univdate.war",
  }
  
  class {'dtg::firewall::publichttp':}
}
