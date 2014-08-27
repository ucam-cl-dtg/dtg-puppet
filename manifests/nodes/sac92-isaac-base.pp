node /(\w+-)?isaac(-\w+)?(.+)?/ {
  include 'dtg::minimal'
  
  User<|title == sac92 |> { groups +>[ 'adm' ]}
  
  # download api content repo from private repo (TODO)
  file { "/local/data/rutherford/":
    ensure => "directory",
    owner  => "tomcat7",
    group  => "tomcat7",
    mode   => 644,
  }
  ->
  file { "/local/data/rutherford/keys/":
    ensure => "directory",
    owner  => "tomcat7",
    group  => "tomcat7",
    mode   => 640,
  }
  ->
  file { "/local/data/rutherford/git-contentstore":
    ensure => "directory",
    owner  => "tomcat7",
    group  => "tomcat7",
    mode   => 644,
  }

  # download front-end code from public repository
  vcsrepo { "/var/isaac-app":
    ensure => present,
    provider => git,
    source => 'https://github.com/ucam-cl-dtg/isaac-app.git',
    owner    => 'tomcat7',
    group    => 'tomcat7'
  }
  ->
  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'isaac-server':
    source => 'puppet:///modules/dtg/apache/isaac-server.conf',
  } 
  
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
    # Note: This will give access to the jenkins server to enable deployments from the CI process.
    ensure => file,
    mode => '0644',        
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
   }
  
  file_line{"tomcat-memory-increase":
    line => 'JAVA_OPTS="-Djava.awt.headless=true -Xms512m -Xmx1024m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC"',
    path => "/etc/default/tomcat7",
    notify => Service['tomcat7'],
    match => '^JAVA_OPTS="-Djava\.awt\.headless=true.*'
  }    
  
  class {'dtg::firewall::publichttp':}

  $packages = ['maven2','openjdk-7-jdk','rssh','mongodb']
  package{$packages:
    ensure => installed
  }
  ->
  file_line { 'rssh-allow-scp':
    line => 'allowscp',
    path => '/etc/rssh.conf', 
  }
  ->
  file_line { 'rssh-allow-rsync':
    line => 'allowrsync',
    path => '/etc/rssh.conf', 
  }

  class { 'dtg::acr31-rutherford::apt_elasticsearch': stage => 'repos' }
  package { ['elasticsearch']:
      ensure => installed,
      require => Apt::Source['elasticsearch-source']
  }
  ->
  service { "elasticsearch":
    ensure => "running"
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

if ( $::monitor ) {
  nagios::monitor { 'isaac-live':
    parents    => 'nas04',
    address    => 'isaac-live.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' , 'http-servers' ],
  }
  munin::gatherer::configure_node { 'isaac-live': }

  nagios::monitor { 'isaac-physics':
    parents    => ['isaac-live', 'balancer'],
    address    => 'isaacphysics.org',
    hostgroups => ['https-servers'],
  }
}
