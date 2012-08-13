
# Setup unattended security updates using the specified email address
# to notify when these occur (and tell about the need to reboot)
class dtg::unattendedupgrades ($unattended_upgrade_notify_emailaddress) {
  file {'/etc/apt/apt.conf.d/10periodic':
    ensure => file,
    source => 'puppet:///modules/dtg/apt/10periodic',
    owner  => 'root',
    group  => 'adm',
  }
  file {'/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure  => file,
    content => template('dtg/apt/50unattended-upgrades.erb'),
    owner   => 'root',
    group   => 'adm',
  }
}
