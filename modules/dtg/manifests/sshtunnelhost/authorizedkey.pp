define dtg::sshtunnelhost::authorizedkey($username, $destination) {
  $keyarray = split($title, ' ')
  $keyname = $keyarray[0]
  ssh_authorized_key { "${keyname},${username}":
    ensure  => present,
    type    => $keyarray[1],
    key     => $keyarray[2],
    user    => $username,
    options => ['no-pty','no-X11-forwarding',"permitopen=\"${destination}\"",'command="/bin/echo do-not-send-commands"'],
  }
}
