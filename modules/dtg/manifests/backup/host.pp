# Configure a host to have a place and user for taking backups
class dtg::backup::host($directory, $user = 'backup', $home = undef, $key = undef) {
  if $home == undef {
    $realhome = "/home/${user}"
  } else {
    $realhome = $home
  }
  if $key == undef {
    $realkey = "${realhome}/.ssh/id_rsa"
  } else {
    $realkey = $key
  }
  group {$user:
    ensure => present,
  }
  user {$user:
    ensure   => present,
    password => '*',
    shell    => '/bin/sh',
    gid      => $user,
  }
  file{$realhome:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  dtg::sshkeygen{'backup':
    homedir => $realhome
  }

  file{$directory:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0701',#Backups should not be readable by anyone else - needs to be executable for 'others'
  }
  # Set sending address for $user to dtg-infra
  file_line {"${user}email":
    ensure  => present,
    path    => '/etc/email-addresses',
    line    => "${user}: dtg-infra@cl.cam.ac.uk",
    require => [Package['exim'],User[$user]],
  }
}
