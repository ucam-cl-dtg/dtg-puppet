# Generate an ssh key for a server user
# Name is the user and group to use, assuming /svr/${user}/ as home dir
define dtg::sshkeygen {
  $user = $name
  file {"/srv/${user}/.ssh/":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0700',
  }
  exec {"gen-${user}-sshkey":
    command => "sudo -H -u ${user} -g ${user} ssh-keygen -q -N '' -t rsa -f /srv/${user}/.ssh/id_rsa",
    creates => "/srv/${user}/.ssh/id_rsa",
    require => File["/srv/${user}/.ssh/"],
  }
}
