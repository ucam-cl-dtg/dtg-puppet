# Exim configuration for client servers telling them which smtp server to use
# $smarthost will be used as the dc_smarthost
# $mail_domain will be used for dc_readhost
# $local_interfaces will be used for dc_local_interfaces
class exim::satellite ($local_interfaces, $smarthost, $relay_nets, $mail_domain) {
  package {'exim':
    ensure => present,
    name   => 'exim4-daemon-light',
  }
  file {'/etc/exim4/update-exim4.conf.conf':
    ensure  => file,
    content => template('exim/update-exim4.conf.conf.erb'),
    require => Package['exim'],
    notify  => Exec['update-exim4.conf'],
  }
  file {'/etc/mailname':
    ensure  => file,
    content => $mail_domain,
    notify  => Exec['update-exim4.conf'],
  }
  file {'/etc/exim4/conf.d/main/00_local_macros':
    source  => 'puppet:///modules/exim/00_local_macros',
    require => Package['exim'],
    notify  => Exec['update-exim4.conf'],
  }
  file {'/etc/exim4/conf.d/transport/30_exim4-config_remote_smtp_smarthost':
    source  => 'puppet:///modules/exim/30_exim4-config_remote_smtp_smarthost',
    require => Package['exim'],
    notify  => Exec['update-exim4.conf'],
  }

  exec {'update-exim4.conf':
    refreshonly => true,
  }

  package {'mailx':
    ensure => present,
    name   => 'bsd-mailx',
  }
  package {'heirloom-mailx':
    ensure  => absent,
    require => Package['mailx'],
  }
}
