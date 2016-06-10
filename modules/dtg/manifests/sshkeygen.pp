# Generate an ssh key for a server user
# Name is the user and group to use, assuming /svr/${user}/ as home dir unless specified
define dtg::sshkeygen ($homedir = undef) {
  $user = $name
  if ($homedir) {
    $sshdir = "$homedir/.ssh/"
  } else {
    $sshdir = "/srv/${user}/.ssh/"
  }
  file {$sshdir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0700',
  }
  $sshfile = "${sshdir}id_rsa"
  exec {"gen-${user}-sshkey":
    command => "ssh-keygen -q -N '' -t rsa -b 4096 -f ${sshfile}",
    user    => $user,
    group   => $group,
    creates => $sshfile,
    require => File[$sshdir],
  }
}
