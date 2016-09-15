# set ownertrust for a given key
define gpg::owner_trust( $fingerprint, $user = 'root', $level = 6, $keyserver = '', $homedir = '/root' ) {
  $keyserver_arg = $keyserver ? {
    '' => '',
    default => "--keyserver ${keyserver}"
  }

  # ensure the key is in the key ring
  exec { "gpg-recv-key-${user}-${fingerprint}":
    command     => "gpg ${keyserver_arg} --recv-key ${fingerprint}",
    require     => [ Package[gnupg] ],
    user        => $user,
    environment => "HOME=${homedir}",
    unless      => "gpg --list-key ${fingerprint} 2>&1 >/dev/null"
  }
  # provide ownertrust
  exec { "gpg-ownertrust-${user}-${fingerprint}":
    command     => "printf '${fingerprint}:${level}\\n'\$(gpg --export-ownertrust) | gpg --import-ownertrust",
    require     => [ Package['gnupg'], Exec["gpg-recv-key-${user}-${fingerprint}"] ],
    user        => $user,
    environment => "HOME=${homedir}",
    unless      => "gpg --export-ownertrust | grep ${fingerprint} >/dev/null"
  }
}
