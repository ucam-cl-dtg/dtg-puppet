
# Setup unattended security updates using the specified email address
# to notify when these occur (and tell about the need to reboot)
class dtg::unattendedupgrades ($unattended_upgrade_notify_emailaddress) {
  file {'/etc/apt/apt.conf.d/10periodic':
    ensure => file,
    source => 'puppet:///modules/dtg/apt/10periodic',
    owner  => 'root',
    group  => 'adm',
  }
  file {'/etc/apt/apt.conf.d/20auto-upgrades':
    ensure => file,
    source => 'puppet:///modules/dtg/apt/20auto-upgrades',
    owner  => 'root',
    group  => 'adm',
  }
  file {'/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure  => file,
    content => template('dtg/apt/50unattended-upgrades.erb'),
    owner   => 'root',
    group   => 'adm',
  }
  file {'/etc/cron.daily/apt':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode    => '0755',
  }
  package {'debian-goodies':
    ensure => installed,
  } ->
  file {'/usr/local/sbin/postupdate-service-restart':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/sbin/postupdate-service-restart'
  }
  file_line {'apt postupdate-service-restart':
    ensure => present,
    path   => '/etc/cron.daily/apt',
    line   => 'postupdate-service-restart',
  }
  file {'/usr/local/etc/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file {'/usr/local/etc/checkrestart_blacklist':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/sbin/checkrestart_blacklist'
  }
}
