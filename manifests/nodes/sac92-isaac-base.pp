node /(\w+-)?isaac(-\w+)?(.+)?/ {
  include 'dtg::minimal'
  
  $tomcat_version = '8'

  User<|title == sac92 |> { groups +>[ 'adm' ]}
  
  # download api content repo from private repo (TODO)
  file { '/local/data/rutherford/':
    ensure => 'directory',
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0644',
  }
  
  file { '/local/data/rutherford/keys/':
    ensure => 'directory',
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0640',
  }
  
  file { ['/local/data/rutherford/git-contentstore', '/local/data/rutherford/conf']:
    ensure => 'directory',
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0644',
  }

  # download front-end code from public repository
  vcsrepo { '/var/isaac-app':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ucam-cl-dtg/isaac-app.git',
    owner    => "tomcat${tomcat_version}",
    group    => "tomcat${tomcat_version}"
  }
  ->
  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'isaac-server':
    source => 'puppet:///modules/dtg/apache/isaac-server.conf',
  }
  
  class { 'postgresql::globals':
    version => '9.4',
  }
  ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '127.0.0.1/32',
    listen_addresses           => '*',
    ipv4acls                   => ['hostssl all all 127.0.0.1/32 md5']
  }
  ->
  postgresql::server::db{'rutherford':
    user     => 'rutherford',
    password => 'rutherf0rd',
    encoding => 'UTF-8',
    grant    => 'ALL'
  }

  class {'dtg::tomcat': version => $tomcat_version}
  ->
  user { "tomcat${tomcat_version}":
    shell => '/usr/bin/rssh'
  }
  ->
  file { "/usr/share/tomcat${tomcat_version}/.ssh":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  ->
  file {"/usr/share/tomcat${tomcat_version}/.ssh/authorized_keys":
    # Note: This will give access to the jenkins server to enable deployments
    # from the CI process.
    ensure  => file,
    mode    => '0644',
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
  }
  
  file_line{'tomcat-memory-increase':
    line   => 'JAVA_OPTS="-Djava.awt.headless=true -Xms512m -Xmx1024m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC"',
    path   => "/etc/default/tomcat${tomcat_version}",
    notify => Service["tomcat${tomcat_version}"],
    match  => '^JAVA_OPTS="-Djava\.awt\.headless=true.*'
  }
  
  class {'dtg::firewall::publichttp':}

  $packages = ['maven2','openjdk-7-jdk','rssh','mongodb']
  package{$packages:
    ensure => installed
  }
  
  file_line { 'rssh-allow-scp':
    line    => 'allowscp',
    path    => '/etc/rssh.conf',
    require => Package['rssh'],
  }
  
  file_line { 'rssh-allow-rsync':
    line    => 'allowrsync',
    path    => '/etc/rssh.conf',
    require => Package['rssh'],
  }
  
  # dbbackup user
  user {'isaac':
    ensure => present,
    shell  => '/bin/bash',
    home   => '/usr/share/isaac'
  }

  # MongoDB Backup
  file { '/local/data/rutherford/database-backup/mongodb':
    ensure => 'directory',
    owner  => 'mongodb',
    group  => 'root',
    mode   => '0755',
  }
  ->
  file { '/local/data/rutherford/isaac-mongodb-backup.sh':
      mode   => '0755',
      owner  => mongodb,
      group  => root,
      source => 'puppet:///modules/dtg/isaac/mongodb/isaac-mongodb-backup.sh'
  }
  ->
  cron {'isaac-backups':
    command => '/local/data/rutherford/isaac-mongodb-backup.sh',
    user    => mongodb,
    hour    => 0,
    minute  => 0
  }

  #Postgres Backup
  file { '/local/data/rutherford/database-backup/postgresql':
    ensure => 'directory',
    owner  => 'postgres',
    group  => 'root',
    mode   => '0755',
  }
  ->
  file { '/local/data/rutherford/isaac-postgres-backup.sh':
      mode   => '0755',
      owner  => postgres,
      group  => root,
      source => 'puppet:///modules/dtg/isaac/postgres/isaac-postgres-backup.sh'
  }
  ->
  cron {'isaac-backups':
    command => '/local/data/rutherford/isaac-postgres-backup.sh',
    user    => postgres,
    hour    => 0,
    minute  => 0
  }


  class { 'dtg::apt_elasticsearch': stage => 'repos' }
  package { ['elasticsearch']:
      ensure  => installed,
      require => Apt::Source['elasticsearch-source']
  }
  ->
  service { 'elasticsearch':
    ensure => 'running'
  }
}

class dtg::apt_elasticsearch {
  apt::key { 'elasticsearch-key':
    key        =>'D88E42B4',
    key_source => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  apt::source { 'elasticsearch-source':
        location    => 'http://packages.elasticsearch.org/elasticsearch/1.4/debian',
        release     => 'stable',
        repos       => 'main',
        include_src => false,
        key         =>'D88E42B4',
        key_source  => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  apt::source { 'elasticsearch-logstash':
        location    => 'http://packages.elasticsearch.org/logstash/1.3/debian',
        release     => 'stable',
        repos       => 'main',
        include_src => false
  }
}
