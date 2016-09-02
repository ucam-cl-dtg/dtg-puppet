class gpg {

  package{'gnupg':
    ensure => installed,
  }

  file { '/usr/local/sbin/gpg-root-needs-expiration-extended':
      source => 'puppet:///modules/gpg/gpg-root-needs-expiration-extended',
      owner  => root,
      group  => root,
      mode   => '0755'
  }

  file { '/usr/local/sbin/gpg-extend-root-expiration':
      source => 'puppet:///modules/gpg/gpg-extend-root-expiration',
      owner  => root,
      group  => root,
      mode   => '0755'
  }
}
