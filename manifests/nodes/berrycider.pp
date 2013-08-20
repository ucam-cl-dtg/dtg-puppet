node /berrycider(-\d+)?/ {

  $dashboard_version = "1.0.2"
  $handins_version   = "0.0.2"
  $questions_version = "0.0.1"
  $signups_version   = "0.0.1"

  include 'dtg::minimal'
  
  class {'dtg::tomcat': version => '7'}
  ->
  class {'dtg::firewall::publichttp':}
  ->
  class {'dtg::firewall::80to8080':}
  ->
  dtg::nexus::fetch{"download-dashboard":
    groupID => "uk.ac.cam.cl.dtg.teaching",
    artifact_name => "dashboard",
    artifact_version => $dashboard_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/ott-dashboard",
    symlink => "/var/lib/tomcat7/webapps/dashboard.war",
  }
  ->
  dtg::nexus::fetch{"download-handins":
    groupID => "uk.ac.cam.cl.dtg.teaching",
    artifact_name => "handins",
    artifact_version => $handins_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/ott-handins",
    symlink => "/var/lib/tomcat7/webapps/handins.war",
  }
  ->
  file {'/local/data/handins':
    ensure => directory,
    group => "tomcat7",
    mode => "a=xr,ug+wrx,g+s"
  }
  ->
  dtg::nexus::fetch{"download-questions":
    groupID => "uk.ac.cam.cl.dtg.teaching",
    artifact_name => "questions",
    artifact_version => $questions_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/ott-questions",
    symlink => "/var/lib/tomcat7/webapps/questions.war",
  }
  ->
  dtg::nexus::fetch{"download-signups":
    groupID => "uk.ac.cam.cl.dtg.teaching",
    artifact_name => "signups",
    artifact_version => $signups_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/ott-signups",
    symlink => "/var/lib/tomcat7/webapps/signups.war",
  }
  class { 'postgresql::server': 
    config_hash => { 
      'ip_mask_deny_postgres_user' => '0.0.0.0/0', 
      'ip_mask_allow_all_users' => '127.0.0.1/32', 
      'listen_addresses' => '*', 
      'ipv4acls' => ['hostssl all all 127.0.0.1/32 md5']
    }
  }
  ->
  postgresql::db{'handins':
    user => "handins",
    password => "handins",
    charset => "UTF-8",
    grant => "ALL"
  }
  ->
  postgresql::db{'notifications':
    user => "signups",
    password => "signups",
    charset => "UTF-8",
    grant => "ALL"
  }
  ->
  postgresql::db{'questions':
    user => "questions",
    password => "questions",
    charset => "UTF-8",
    grant => "ALL"
  }
  ->
  postgresql::db{'signups':
    user => "signups",
    password => "signups",
    charset => "UTF-8",
    grant => "ALL"
  }

  $packages = ['maven2','openjdk-7-jdk','puppet-el']
  package{$packages:
    ensure => installed,
  }
  
}
