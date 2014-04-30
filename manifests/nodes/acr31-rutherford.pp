node /acr31-rutherford(-\d+)?/ {
  include 'dtg::minimal'
  
  class {'dtg::tomcat': version => '7'}
  ->
  user { 'tomcat7':
    shell => '/usr/bin/rssh'
  }
  
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}

  class { 'postgresql::globals':
    version => '9.1'
  }
  ->
  class { 'postgresql::server': 
    ip_mask_deny_postgres_user => '0.0.0.0/0', 
    ip_mask_allow_all_users => '127.0.0.1/32', 
    listen_addresses => '*', 
    ipv4acls => ['hostssl all all 127.0.0.1/32 md5']
  }
  ->
  postgresql::server::db{'rutherford':
    user => "rutherford",
    password => "rutherford",
    encoding => "UTF-8",
    grant => "ALL"
  }

  firewall { '011 accept all http on 8080':
    proto   => 'tcp',
    dport   => '8080',
    action  => 'accept',
  }

  $packages = ['maven2','openjdk-7-jdk','rssh','mongodb']
  package{$packages:
    ensure => installed,
    require => Exec['apt-get update']
  }
  
  ->
  file_line { 'rssh-allow-sftp':
    line => 'allowsftp',
    path => '/etc/rssh.conf', 
  }
}

if ( $::monitor ) {
  nagios::monitor { 'rutherford':
    parents    => '',
    address    => 'rutherford.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' , 'http-servers' ],
  }
  munin::gatherer::configure_node { 'rutherford': }
}
