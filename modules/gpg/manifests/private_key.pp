# Ensure user has a gpg private key. Typically this define should be used to ensure 
# that the user has a password-less gpg key to be used in scripts
define gpg::private_key( $homedir, $passphrase = '', $expire = '31536000', $length = 2048, $uid = '' ) {

  $user = $title

  $calculated_uid = $uid ? {
    '' => "${user}@${::fqdn}",
    default => $uid
  }

  exec { "gpg-ssh-genkey-${user}":
      command     => "ssh-keygen  -t rsa -b '${length}' -f '${homedir}/.ssh/id_rsa' -N ''",
      environment => "HOME=${homedir}",
      require     =>  [ Package['gnupg'], Package['openssh-client'] ],
      user        => $user,
      unless      => "test -f '${homedir}/.ssh/id_rsa'"
  }
  exec { "gpg-pem2openpgp-${user}":
      command     => "pem2openpgp ${calculated_uid} < '${homedir}/.ssh/id_rsa' | gpg --import",
      environment => [ "HOME=${homedir}", "PEM2OPENPGP_EXPIRATION=${expire}" ],
      require     =>  [ Package['monkeysphere'], Package['openssh-client'], Exec["gpg-ssh-genkey-${user}" ] ],
      user        => $user,
      unless      => "gpg --list-secret-key '${calculated_uid}' >/dev/null"
  }
  exec { "gpg-extend-expiration-${user}":
      command     => '/usr/local/sbin/gpg-extend-root-expiration',
      environment => [ "HOME=${homedir}"  ],
      require     =>  [ File['/usr/local/sbin/gpg-root-needs-expiration-extended'], File['/usr/local/sbin/gpg-extend-root-expiration'], Exec["gpg-ssh-genkey-${user}" ], Exec["gpg-pem2openpgp-${user}"] ],
      user        => $user,
      onlyif      => '/usr/local/sbin/gpg-root-needs-expiration-extended'
  }
  case $passphrase {
    '': { }
    default: {
      exec { "gpg-add-passphrase-${user}":
        command     => "printf '${passphrase}\\n${passphrase}\\nsave\\n' | gpg --command-fd 0 --passphrase-fd 0 --no-tty --edit-key '${calculated_uid}' password",
        require     =>  [ Exec["gpg-pem2openpgp-${user}"] ],
        environment => "HOME=${homedir}",
        user        => $user,
        unless      => "test $(gpg --export-secret-keys | gpg --list-packets | grep -c 'encrypted stuff follows') -eq 2"
      }
    }
  }
}
