node /(\w+-)?isaac-(dev|staging|live)(.+)?/ {
  include 'dtg::minimal'

  class {'dtg::isaac':}

  $tomcat_version = '8'

  # download api content repo from private repo (TODO)
  file { '/local/data/rutherford/':
    ensure => 'directory',
    owner  => "tomcat${tomcat_version}",
    group  => "isaac",
    mode   => '0644',
  }
  
  file { '/local/data/rutherford/keys/':
    ensure => 'directory',
    owner  => "tomcat${tomcat_version}",
    group  => "isaac",
    mode   => '0640',
  }
  
  file { ['/local/data/rutherford/git-contentstore', '/local/data/rutherford/conf']:
    ensure => 'directory',
    owner  => "tomcat${tomcat_version}",
    group  => "isaac",
    mode   => '0644',
  }

  # download front-end code from public repository
  vcsrepo { '/var/isaac-app':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ucam-cl-dtg/isaac-app.git',
    owner    => "tomcat${tomcat_version}",
    group    => "isaac"
  }

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
  
  # if we are on live we want to use a larger data volume to store the postgres data.
  # TODO: rename mount point (as it is postgres that uses it not mongo) and create volumes on dev and staging as well so we don't have to do this.
  if ( $::fqdn =~ /(\w+-)?isaac-live/ ) {
    class { 'postgresql::globals':
      version => '9.4',
      datadir => '/local/mongo-data-store/postgres/'
    }
  } else {
    class { 'postgresql::globals':
      version => '9.4',
    }
  }

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
    line   => 'JAVA_OPTS="-Djava.awt.headless=true -Xms512m -Xmx2048m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC"',
    path   => "/etc/default/tomcat${tomcat_version}",
    notify => Service["tomcat${tomcat_version}"],
    match  => '^JAVA_OPTS="-Djava\.awt\.headless=true.*'
  }
  
  class {'dtg::firewall::privatehttp':}

  $packages = ['maven2','openjdk-7-jdk','rssh','docker']
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

  #Database Backup
  if ( $::fqdn =~ /(\w+-)?isaac-live/ ) {
    file { '/local/data/rutherford/database-backup':
      ensure => link,
      target => '/local/logs/database-backup',
      owner  => 'postgres',
      group  => 'isaac',
      mode   => '0755',
    }
  } else {
    file { '/local/data/rutherford/database-backup':
      ensure => 'directory',
      owner  => 'postgres',
      group  => 'isaac',
      mode   => '0755',
    }
  }

  file { '/local/data/rutherford/database-backup/combined':
    ensure => 'directory',
    owner  => 'postgres',
    group  => 'isaac',
    mode   => '0755',
  }
  ->
  file { '/local/data/rutherford/isaac-database-backup.sh':
      mode   => '0755',
      owner  => postgres,
      group  => isaac,
      source => 'puppet:///modules/dtg/isaac/isaac-database-backup.sh'
  }
  ->
  file { '/local/data/rutherford/database-backup/isaac-database-backup.log':
      path => '/local/data/rutherford/database-backup/isaac-database-backup.log',
      ensure  => present,
      replace => false,
      mode   => '0755',
      owner  => postgres,
      group  => isaac,
      content => "# Database backup log files"
  }
  -> 
  cron {'isaac-backup-postgresql':
    ensure => absent
  }
  -> 
  cron {'isaac-backup-mongodb':
    ensure => absent
  }
  ->
  cron {'isaac-backup-database':
    command => '/local/data/rutherford/isaac-database-backup.sh >> /local/data/rutherford/database-backup/isaac-database-backup.log',
    user    => postgres,
    hour    => 0,
    minute  => 0
  }

#  # puppet repository permissions
#  File <| title == '/etc/puppet-bare' |> {
#    recurse => true,
#    owner  => 'root',
#    group  => 'isaac',
#    mode   => 'ug+rwx',
#  }
#  ->
#  File <| title == '/etc/puppet' |> {
#    recurse => true,
#    owner  => 'root',
#    group  => 'isaac',
#    mode   => 'ug+rwx',
#  }


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
  apt::source { 'elasticsearch-source':
        location    => 'http://packages.elasticsearch.org/elasticsearch/1.4/debian',
        release     => 'stable',
        repos       => 'main',
        include     =>  {'src' => false},
        key         =>  {
          'id'      => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          'source'  => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        }
  }

  apt::source { 'elasticsearch-logstash':
        location    => 'http://packages.elasticsearch.org/logstash/1.3/debian',
        release     => 'stable',
        repos       => 'main',
        include     =>  {'src' => false}
  }
}
