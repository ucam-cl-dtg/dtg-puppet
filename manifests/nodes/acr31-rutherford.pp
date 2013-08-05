node /acr31-rutherford(-\d+)?/ {
  include 'dtg::minimal'
  
  class {'dtg::tomcat': version => '7'}
  
  class {'dtg::firewall::publichttp':}

  class { 'postgresql::server': 
    config_hash => { 
      'ip_mask_deny_postgres_user' => '0.0.0.0/0', 
      'ip_mask_allow_all_users' => '127.0.0.1/32', 
      'listen_addresses' => '*', 
      'ipv4acls' => ['hostssl all all 127.0.0.1/32 md5']
    }
  }
  ->
  postgresql::db{'rutherford':
    user => "rutherford",
    password => "rutherford",
    charset => "UTF-8",
    grant => "ALL"
  }

  firewall { '011 accept all http on 8080':
    proto   => 'tcp',
    dport   => '8080',
    action  => 'accept',
  }

  $packages = ['maven2']
  package{$packages:
    ensure => installed,
  }
  
}
