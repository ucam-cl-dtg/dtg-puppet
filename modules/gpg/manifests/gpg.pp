class m_gpg {

  package{'gnupg':
    ensure => installed,
  }

  file { "/usr/local/sbin/mf-gpg-root-needs-expiration-extended":
      source => "puppet:///modules/mayfirst/gpg/mf-gpg-root-needs-expiration-extended",
      owner => root,
      group => root,
      mode => 0755
  }

  file { "/usr/local/sbin/mf-gpg-extend-root-expiration":
      source => "puppet:///modules/mayfirst/gpg/mf-gpg-extend-root-expiration",
      owner => root,
      group => root,
      mode => 0755
  }
}

# gpg user related defines

# Ensure user has a gpg private key. Typically this define should be used to ensure 
# that the user has a password-less gpg key to be used in scripts
define m_gpg::private_key( $homedir, $passphrase = '', $expire = '31536000', $length = 2048, $uid = '' ) {

  $user = $title

  $calculated_uid = $uid ? {
    '' => "$user@$::hostname.mayfirst.org",
    default => $uid
  }

  exec { "gpg-ssh-genkey-$user":
      command => "ssh-keygen  -t rsa -b '$length' -f '$homedir/.ssh/id_rsa' -N ''",
      environment => "HOME=$homedir",
      require =>  [ Package["gnupg"], Package["openssh-client"] ],
      user => $user,
      unless => "test -f '$homedir/.ssh/id_rsa'"
  }
  exec { "gpg-pem2openpgp-$user":
      command => "pem2openpgp $user@$::hostname.mayfirst.org < '$homedir/.ssh/id_rsa' | gpg --import",
      environment => [ "HOME=$homedir", "PEM2OPENPGP_EXPIRATION=$expire" ],
      require =>  [ Package["monkeysphere"], Package["openssh-client"], Exec["gpg-ssh-genkey-$user" ] ],
      user => $user,
      unless => "gpg --list-secret-key '$calculated_uid' >/dev/null"
  }
  exec { "gpg-extend-expiration-$user":
      command => "/usr/local/sbin/mf-gpg-extend-root-expiration",
      environment => [ "HOME=$homedir"  ],
      require =>  [ File["/usr/local/sbin/mf-gpg-root-needs-expiration-extended"], File["/usr/local/sbin/mf-gpg-extend-root-expiration"], Exec["gpg-ssh-genkey-$user" ], Exec["gpg-pem2openpgp-$user"] ],
      user => $user,
      onlyif => "/usr/local/sbin/mf-gpg-root-needs-expiration-extended"
  }
  case $passphrase {
    '': { }
    default: { 
      exec { "gpg-add-passphrase-$user":
        command => "printf '$passphrase\n$passphrase\nsave\n' |gpg --command-fd 0 --passphrase-fd 0 --no-tty --edit-key root@$::hostname.mayfirst.org password",
        require =>  [ Exec["gpg-pem2openpgp-$user"] ],
        environment => "HOME=$homedir",
        user => $user,
        unless => "test $(gpg --export-secret-keys | gpg --list-packets | grep -c 'encrypted stuff follows') -eq 2"
      }
    }
  }
}

# publish key to a keysrver
define m_gpg::publish_user_key ( $keyserver = '' ){
  $user = $title

  $keyserver_arg = $keyserver ? {
    '' => '',
    default => "--keyserver $keyserver"
  }

  exec { "gpg-send-key-$user":
    command => "gpg $keyserver_arg --send-key $(gpg --list-secret-key --with-colons | grep ^sec | cut -d: -f5)",
    require => [ Package["gnupg"], Exec["gpg-pem2openpgp-$user" ] ],
    user => $user,
  }

}

# set ownertrust for a given key
define m_gpg::owner_trust( $fingerprint, $user = 'root', $level = 6, $keyserver = '', $homedir = "/root" ) {
  $keyserver_arg = $keyserver ? {
    '' => '',
    default => "--keyserver $keyserver"
  }

  # ensure the key is in the key ring
  exec { "gpg-recv-key-$user-$fingerprint":
    command => "gpg $keyserver_arg --recv-key $fingerprint",
    require => [ Package[gnupg] ],
    user => $user,
    environment => "HOME=$homedir",
    unless => "gpg --list-key $fingerprint 2>&1 >/dev/null"
  }
  # provide ownertrust
  exec { "gpg-ownertrust-$user-$fingerprint":
    command => "printf '$fingerprint:$level\n'\$(gpg --export-ownertrust) | gpg --import-ownertrust",
    require => [ Package["gnupg"], Exec["gpg-recv-key-$user-$fingerprint"] ],
    user => $user,
    environment => "HOME=$homedir",
    unless => "gpg --export-ownertrust | grep $fingerprint >/dev/null"
  }
}
