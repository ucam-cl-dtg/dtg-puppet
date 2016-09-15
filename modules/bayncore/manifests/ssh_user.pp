define bayncore::ssh_user($real_name,$uid,$ensure = 'present') {
  $username = $title
  user { $username:
    ensure     => $ensure,
    comment    => "${real_name} <${email}>",
    home       => "/home/${username}",
    shell      => '/bin/bash',
    groups     => [],
    uid        => $uid,
    membership => 'minimum',
    password   => '*',
  }
  ->
  group { $username:
    ensure  => $ensure,
    require => User[$username],
    gid     => $uid,
  }
}
