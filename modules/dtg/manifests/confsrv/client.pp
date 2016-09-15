# Use a if $::fqdn to put this in the node file for servers
# which need access to secrets stored on confsrv
# title: hostname (without the .dtg...)
# keyids: the monkeysphere key ids for the user
define dtg::confsrv::client ( $keyids ) {
  $host = $title
  group { $host :}
  user { $host :
    gid    => $host,
    groups => [ 'dtg-servers' ],
  }
  monkeysphere::authorized_user_ids { $host :
    user_ids => $keyids
  }
}
