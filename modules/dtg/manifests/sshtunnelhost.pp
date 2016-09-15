# keys array of arrays of "name type public key"
define dtg::sshtunnelhost ($username, $home, $destination, $keys) {
  group { $username: ensure => present, }
  user { $username:
    gid     => $username,
    comment => 'SSH tunnel host user',
    ensure  => present,
#    purge_ssh_keys => true, # Only available in later versions of puppet
    home    => $home,
  }
  file { $home:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
  }
  file { "${home}/.ssh":
    ensure => directory,
    owner  => $username,
    group  => $username,
    mode   => '0500',
  }
  # This will become useful in later versions of puppet but is not available in the 2.7 puppet installed on the entropy server
  # 
  #   each($keys) |$keyarray| {
  #     ssh_authorized_key { $keyarray[0]:
  #       type    => $keyarray[1],
  #       key     => $keyarray[2],
  #       user    => $username,
  #       ensure  => present,
  #       options => ['no-pty','no-X11-forwarding',"permitopen=\"$destination\"",'command="/bin/echo do-not-send-commands"'],
  #   }
  # Hack to implement the above but without nice features for doing so
  dtg::sshtunnelhost::authorizedkey{$keys:
    username    => $username,
    destination => $destination,
  }
}
