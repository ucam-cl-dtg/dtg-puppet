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
  }
  package {'mailx':
    name   => 'bsd-mailx',
    ensure => present,
  }
}
