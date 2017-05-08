# This will set up nexus listening on port 8081
class dtg::maven::nexus (
  $version = '2.12.1-01',
  $mirror_url = 'http://download.sonatype.com/nexus/oss/'
){
  $download_file = "nexus-${version}-bundle.tar.gz"
  $download_url = "${mirror_url}${download_file}"
  $download_to = "/srv/nexus/${download_file}"
  $nexus_dir = "/srv/nexus/nexus-${version}"
  group {'nexus':
    ensure => present,
  }
  user {'nexus':
    ensure => present,
    gid    => 'nexus',
  }
  file {'/local/data/nexus':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '2755',
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
  file {'/srv/nexus/.ssh/':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '0700',
  }
  file {'/srv/nexus/.ssh/authorized_keys':
    ensure => file,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '0600',
  }
  dtg::backup::serversetup{'Nexus repositories':
    backup_directory   => '/srv/nexus/sonatype-work/',
    script_destination => '/srv/nexus/backup',
    user               => 'nexus',
    home               => '/srv/nexus/',
  }
  file {'/srv/nexus/sonatype-work/nexus':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '2775',
  }
  exec {'nexus_download':
    unless    => "test -d ${nexus_dir}",
    command   => "curl --location -o '${download_to}' '${download_url}'",
    creates   => $download_to,
    logoutput => 'on_failure',
    require   => [File['/srv/nexus/'], Package['curl']],
  }
  file {$download_to:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
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
    ensure  => link,
    target  => $nexus_dir,
    require => Exec['nexus_extract'],
  }
  file {'/srv/nexus/nexus/conf/nexus.properties':
    ensure  => file,
    source  => 'puppet:///modules/dtg/nexus/conf/nexus.properties',
    owner   => 'nexus',
    group   => 'nexus',
    mode    => '0744',
    require => File['/srv/nexus/nexus/'],
  }
  # Start nexus on reboot
  cron {'nexus':
    ensure  => present,
    command => '/srv/nexus/nexus/bin/nexus start',
    user    => 'nexus',
    special => 'reboot',
    require => File['/srv/nexus/nexus/'],
  }
  package{'default-jre': ensure => present}
  # Start nexus if not already running
  exec {'nexus_start':
    unless    => 'ps x -U nexus | grep java | grep -v grep',
    command   => '/srv/nexus/nexus/bin/nexus start',
    user      => 'nexus',
    logoutput => 'on_failure',
    require   => [File['/srv/nexus/nexus/'], Package['default-jre']],
  }
}
