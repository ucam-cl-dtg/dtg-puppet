class dtg::howlermonkey {
  package { ['python3-requests', 'python3-yaml']:
    ensure => installed,
  }
  -> python::pip { 'howlermonkey':
    ensure  => latest,
    pkgname => 'howlermonkey',
    require => [ Package['python3'] ],
  }
}
