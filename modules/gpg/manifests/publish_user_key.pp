# publish key to a keysrver
define gpg::publish_user_key ( $keyserver = '' ){
  $user = $title

  $keyserver_arg = $keyserver ? {
    '' => '',
    default => "--keyserver ${keyserver}"
  }

  exec { "gpg-send-key-${user}":
    command => "gpg ${keyserver_arg} --send-key $(gpg --list-secret-key --with-colons | grep ^sec | cut -d: -f5)",
    require => [ Package['gnupg'], Exec["gpg-pem2openpgp-${user}" ] ],
    user    => $user,
  }

}
