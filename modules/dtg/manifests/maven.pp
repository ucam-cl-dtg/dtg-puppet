class dtg::maven {
  # Proxy from apache to nexus
  apache::site {'maven':
    source => 'puppet:///modules/dtg/apache/maven.conf',
  }
  class {'dtg::maven::nexus':}
}
# This will set up nexus listening on port 8081
class dtg::maven::nexus (
  $version = '2.1.2',
  $mirror_url = 'http://www.sonatype.org/downloads/'
){
  $download_file = "nexus-${version}-bundle.tar.gz"
  $download_url = "${mirror_url}${download_file}"
  $download_to = "/srv/nexus/${download_file}"
  $nexus_dir = "/srv/nexus/nexus-${version}"
  group {'nexus':}
  user {'nexus':
    gid => 'nexus',
  }
  file {'/local/data/nexus':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '2775',
  }
  file {'/srv/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file {'/srv/nexus/':
    ensure => link,
    target => '/local/data/nexus',
  }
  # TODO(drt24) We should probably grab this from backups rather than
  #  just creating a new directory but this is the correct behaviour for the
  #  first install and we don't have backups working correctly yet.
  file {'/srv/nexus/sonatype-work':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '2775',
  }
  file {'/srv/nexus/sonatype-work/nexus':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '2775',
  }
  exec {'nexus_download':
    unless    => "test -d ${nexus_dir}",
    command   => "curl -o '${download_to}' '${download_url}'",
    creates   => "${download_to}",
    logoutput => 'on_failure',
    require   => [File['/srv/nexus/'], Package['curl']],
  }
  file {$download_to:
    ensure => file,
    owner   => 'root',
    group  => 'root',
    mode   => '0444',
    require => Exec['nexus_download'],
  }
  exec {'nexus_extract':
    command   => "tar -xzf '${download_to}' nexus-${version}",
    cwd       => '/srv/nexus/',
    creates   => $nexus_dir,
    user      => 'nexus',
    group     => 'nexus',
    logoutput => 'on_failure',
    require   => [Exec['nexus_download'], File[$download_to], Package['tar']],
  }
  file {'/srv/nexus/nexus/':
    ensure => link,
    target => $nexus_dir,
    require => Exec['nexus_extract'],
  }
  # Start nexus on reboot
  cron {'nexus':
    command => '/srv/nexus/nexus/bin/nexus',
    user    => 'nexus',
    ensure  => present,
    special => 'reboot',
    require => File['/srv/nexus/nexus/'],
  }
  # Start nexus if not already running
  exec {'nexus_start':
    unless    => 'ps x -U nexus | grep java | grep -v grep',
    command   => '/srv/nexus/nexus/bin/nexus',
    user      => 'nexus',
    logoutput => 'on_failure',
    require   => File['/srv/nexus/nexus/'],
  }
}
