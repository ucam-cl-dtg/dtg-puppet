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
