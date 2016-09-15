class dtg::maven::sshmirror (
  $monkeysphere_keyids
){
  file {'/srv/nexus/sshmirror':
    ensure => directory,
    owner  => 'nexus',
    group  => 'nexus',
    mode   => '0755',
  }
  file {'/usr/local/bin/maven-sshmirror-cron':
    ensure => file,
    mode   => '0755',
    owner  => 'root',
    source => 'puppet:///modules/dtg/nexus/maven-sshmirror-cron',
  }
  cron {'maven-sshmirror':
    command => '/usr/local/bin/maven-sshmirror-cron',
    user    => 'nexus',
    ensure  => 'present',
    minute  => cron_minute('maven-sshmirror'),
    require => File['/usr/local/bin/maven-sshmirror-cron'],
  }
  # People will scp in as the maven user
  group {'maven':
    ensure => present,
  }
  user {'maven':
    gid    => 'maven',
    ensure => present,
    home   => '/home/maven',
  }
  # We need somewhere to store authorized uids and authorized_keys
  file {'/home/maven/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }
  file {'/home/maven/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  monkeysphere::authorized_user_ids { 'maven':
    user_ids => $monkeysphere_keyids,
    dest_dir => '/home/maven/.monkeysphere',
  }
  # Directory to chroot the maven user to and to mount the sshmirror files into
  file {'/srv/maven-sshmirror':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->
  # Need /home/maven inside the chroot but still want to end up at the root of the chroot
  # So just use symlinks
  file {'/srv/maven-sshmirror/home':
    ensure => link,
    target => '/',
  } ->
  file {'/srv/maven-sshmirror/maven':
    ensure => link,
    target => '/',
  }
  file {'/srv/maven-sshmirror/mirror':
    ensure  => directory, # Don't specify owner or group as will change when mounted
    mode    => '0755',
    require => File['/srv/maven-sshmirror'],
  } ->
  file_line{'mount sshmirror ro':
    path => '/etc/fstab',
    line => '/local/data/nexus/sshmirror	/srv/maven-sshmirror/mirror	none	bind,ro,noexec,nosuid,nodev	0	0',
  } ->
  file {'/etc/init/sshmirrormount.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/dtg/nexus/sshmirrormount.conf',
  } ->
  exec {'sshmirror ensure mounted':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => 'start sshmirrormount',
    unless  => 'mount | grep /srv/maven-sshmirror/mirror | grep ro >/dev/null'
  }
  file {'/etc/ssh/sshd_config.d/maven-sshmirror.conf':
    content => '
Match User maven
    ChrootDirectory /srv/maven-sshmirror
    ForceCommand internal-sftp
',
    before  => File['sshd_config'],
  }
}
