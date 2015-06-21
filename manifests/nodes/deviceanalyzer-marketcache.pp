node /deviceanalyzer-marketcache/ {

    include 'dtg::minimal'
    $marketcache_version = '1.0.0-SNAPSHOT'
    $tomcat_version = '8'
    $install_directory = '/local/data/webapps'

    class {'dtg::tomcat': version => $tomcat_version}
    ->
    class {'dtg::firewall::publichttp':}
    ->
    class {'dtg::firewall::80to8080':
      private => false,
    }
    ->
    dtg::nexus::fetch{'download-marketcache':
      groupID               => 'uk.ac.cam.deviceanalyzer.analysis',
      artifact_name         => 'marketcache',
      artifact_version      => $marketcache_version,
      artifact_type         => 'war',
      destination_directory => "${install_directory}/marketcache",
      symlink               => "/var/lib/tomcat${tomcat_version}/webapps/marketcache.war",
    }
    
    class { 'postgresql::globals':
      version => '9.4',
    }
    ->
    class { 'postgresql::server':
      ip_mask_deny_postgres_user => '0.0.0.0/0',
      ip_mask_allow_all_users    => '127.0.0.1/32',
      listen_addresses           => '*',
      ipv4acls                   => ['hostssl all all 127.0.0.1/32 md5'],
    }
    ->
    postgresql::server::db{'marketcache':
      user     => 'marketcache',
      password => 'marketcache',
      encoding => 'UTF-8',
      grant    => 'ALL'
    }    
    ->
    dtg::nexus::fetch{'download-marketcache-backup':
      groupID               => 'uk.ac.cam.deviceanalyzer.analysis',
      artifact_name         => 'marketcache-backup',
      artifact_version      => '1.0.0-SNAPSHOT',
      artifact_type         => 'zip',
      artifact_classifier   => 'live',
      destination_directory => "${install_directory}/marketcache-backup",
      action                => 'unzip'
    }
    ->
    exec{'restore-handins-backup':
      command     => "psql -U marketcache -d marketcache -h localhost -f ${install_directory}/marketcache-backup/marketcache-backup-1.0.0-SNAPSHOT/target/backup.sql",
      environment => 'PGPASSWORD=marketcache',
      path        => '/usr/bin:/bin',
      unless      => 'psql -U marketcache -h localhost -d marketcache -t -c "select * from appdata limit 1"'
    }
    
    
    $packages = ['maven2','openjdk-8-jdk','puppet-el','build-essential','ruby','ruby-dev','zlib1g-dev']
    package{$packages:
      ensure => installed,
    }
    ->
    exec{'install-gem-marketbot':
      command => "gem install market_bot",
      path    => "/usr/bin:/bin",
      unless  => "gem list | grep market_bot",
    }
    
    group {'jenkins':
      ensure => present,
    }
    ->
    user {'jenkins':
      ensure   => present,
      gid      => 'jenkins',
      password => '*',
    }
    ->
    file {'/home/jenkins':
      ensure => directory,
      owner  => 'jenkins',
      group  => 'jenkins',
      mode   => '0755',
    }
    ->
    file {'/home/jenkins/.ssh/':
      ensure => directory,
      owner  => 'jenkins',
      group  => 'jenkins',
      mode   => '0755',
    }
    ->
    file {'/home/jenkins/.ssh/authorized_keys':
      ensure  => file,
      mode    => '0644',
      content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
    }
}

if ( $::monitor ) {
  nagios::monitor { 'deviceanalyzer-marketcache':
    parents    => 'nas04',
    address    => 'deviceanalyzer-marketcache.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  munin::gatherer::configure_node { 'deviceanalyzer-marketcache': }
}
