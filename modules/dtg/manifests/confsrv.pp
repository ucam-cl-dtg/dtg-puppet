class dtg::confsrv {
  file {'/srv/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  group {'puppet-conf':}
  user  {'puppet-conf':
    gid  => 'puppet-conf',
    home => '/srv/puppet-conf'
  }
  file {'/srv/puppet-conf':
    ensure => directory,
    owner  => 'puppet-conf',
    group  => 'puppet-conf',
    mode   => '2755',
  }
  group {'dtg-servers':}
  file {'/srv/puppet-conf/dtg-servers':
    ensure => directory,
    owner  => 'puppet-conf',
    group  => 'dtg-servers',
    mode   => '2750',
  }
  file {'/srv/puppet-conf/dtg-servers/keys/':
    ensure => 'directory',
    owner  => 'puppet-conf',
    group  => 'dtg-servers',
    mode   => '2750',
  }
}
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
