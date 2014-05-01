node /(\w+-)?isaac(-\w+)?(.+)?/ {
  include 'dtg::minimal'
  
  User<|title == sac92 |> { groups +>[ 'adm' ]}
  
  class {'dtg::tomcat': version => '7'}
  ->
  user { 'tomcat7':
    shell => '/usr/bin/rssh'
  }
  ->
  file { "/usr/share/tomcat7/.ssh":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 644,
  }
  ->
  file {'/usr/share/tomcat7/.ssh/authorized_keys':
    ensure => file,
    mode => '0644',        
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
   }
  
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}

  class { 'postgresql::globals':
    version => '9.3'
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
    ensure => installed
  }
  ->
  file_line { 'rssh-allow-sftp':
    line => 'allowsftp',
    path => '/etc/rssh.conf', 
  }

  class { 'dtg::acr31-rutherford::apt_elasticsearch': stage => 'repos' }
  package { ['elasticsearch']:
      ensure => installed,
      require => Apt::Source['elasticsearch-source']
  }
}

class dtg::acr31-rutherford::apt_elasticsearch {
  apt::key { 'elasticsearch-key':
    key =>'D88E42B4',
    key_source => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  apt::source { 'elasticsearch-source':
        location        => "http://packages.elasticsearch.org/elasticsearch/1.0/debian",
        release         => "stable",
        repos           => "main",
        include_src     => false,
        key =>'D88E42B4',
        key_source => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  apt::source { 'elasticsearch-logstash':
        location        => "http://packages.elasticsearch.org/logstash/1.3/debian",
        release         => "stable",
        repos           => "main",
        include_src     => false
  }

}
