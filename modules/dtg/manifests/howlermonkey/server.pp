class dtg::howlermonkey::server {
  include 'dtg::howlermonkey'
  user {'howlermonkey':
    ensure => present,
  }
  systemd::unit_file { 'howlermonkey.service':
    source => 'puppet:///modules/dtg/howlermonkey/howlermonkey.service',
  }
  ~> service { 'howlermonkey':
    ensure  => running,
    enable  => true,
    require => [ Class['dtg::howlermonkey'] ],
  }
}
