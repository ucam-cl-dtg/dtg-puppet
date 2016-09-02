# Exim configuration for client servers telling them which smtp server to use
# $smarthost will be used as the dc_smarthost
# $mail_domain will be used for dc_readhost
class exim::satellite ($smarthost, $mail_domain) {
  package {'exim':
    name   => 'exim4-daemon-light',
    ensure => present,
  }
  file {'/etc/exim4/update-exim4.conf.conf':
    content => template('exim/update-exim4.conf.conf.erb'),
    ensure  => file,
    require => Package['exim'],
    notify  => Exec['update-exim4.conf'],
  }
  file {'/etc/mailname':
    ensure  => file,
    content => $mail_domain,
    notify  => Exec['update-exim4.conf'],
  }

  exec {'update-exim4.conf':
    refreshonly => true,
  }

  package {'mailx':
    name   => 'bsd-mailx',
    ensure => present,
  }
  package {'heirloom-mailx':
    ensure  => absent,
    require => Package['mailx'],
  }
}
