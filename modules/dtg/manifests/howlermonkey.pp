
class dtg::howlermonkey {
  include dtg::packages::howlermonkey
  user {'howlermonkey':
    ensure => present,
  }
  systemd::unit_file { 'howlermonkey.service':
    source => 'puppet:///modules/dtg/howlermonkey/howlermonkey.service',
  }
  ~> service { 'howlermonkey':
    ensure  => running,
    enable  => true,
    require => [ User['howlermonkey'], Python::Pip['howlermonkey'] ],
  }
}

