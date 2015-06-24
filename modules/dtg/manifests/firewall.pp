#iptables firewalling for nodes
# Default setup
class dtg::firewall::default {
  # These defaults ensure that the persistence command is executed after
  # every change to the firewall, and that pre & post classes are run in the
  # right order to avoid potentially locking you out of your box during the
  # first puppet run.
  Firewall {
    notify  => Exec['persist-firewall'],
    before  => Class['dtg::firewall::post'],
    require => Class['dtg::firewall::pre'],
  }
  Firewallchain {
    notify  => Exec['persist-firewall'],
  }
}
class dtg::firewall inherits dtg::firewall::default {
  exec { 'persist-firewall':
    command     => '/sbin/iptables-save > /etc/iptables.rules',
    refreshonly => true,
  }
  file_line { 'restore iptables':
    ensure => present,
    line   => 'pre-up iptables-restore < /etc/iptables.rules',
    path   => '/etc/network/interfaces',
  }
  # Purge unmanaged firewall resources
  #
  # This will clear any existing rules, and make sure that only rules
  # defined in puppet exist on the machine
#  resources { "firewall":
#    purge => true
#  }
  class {'dtg::firewall::pre':}->
  class {'dtg::firewall::post':}
}

# The first rules which do the accepting
class dtg::firewall::pre inherits dtg::firewall::default {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  firewall { '003 accept all ssh':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept',
  }->
  firewall { '004 accept munin from muninserver':
    proto  => 'tcp',
    dport  => '4949',
    source => $::munin_server_ip,
    action => 'accept',
  }
  firewall { '005 accept nfs client':
    proto  => 'tcp',
    dport  => $::nfs_client_port,
    source => $::local_subnet,
    action => 'accept',
  }
}
class dtg::firewall::publichttp inherits dtg::firewall::default {
  firewall { '010 accept all http':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
class dtg::firewall::publichttps inherits dtg::firewall::default {
  firewall { '013 accept all https':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }
}

class dtg::firewall::privatehttp inherits dtg::firewall::default {
  firewall { '010 accept all http from dtg':
    proto  => 'tcp',
    dport  => '80',
    source => $::local_subnet,
    action => 'accept',
  }
}
class dtg::firewall::entropy inherits dtg::firewall::default {
  firewall { '011 accept all entropy requests':
    proto  => 'tcp',
    dport  => '7776',
    action => 'accept',
    source => $::local_subnet,
  }
}
class dtg::firewall::git inherits dtg::firewall::default {
  firewall { '012 accept all git':
    proto  => 'tcp',
    dport  => '9418',
    action => 'accept',
  }
}

define dtg::firewall::postgres ($source, $source_name) {

  require dtg::firewall::default

  firewall { "014 accept postgres requests from $source_name":
    proto  => 'tcp',
    dport  => '5432',
    action => 'accept',
    source => $source,
  }
}

class dtg::firewall::80to8080 ($private = true) inherits dtg::firewall::default {
  firewall { '020 redirect 80 to 8080':
    dport   => '80',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => '8080',
  }
  firewall { '020 redirect 80 to 8080 localhost':
    dport       => '80',
    table       => 'nat',
    chain       => 'OUTPUT',
    jump        => 'REDIRECT',
    toports     => '8080',
    destination => '127.0.0.1/8',
  }
  firewall { '020 accept on 8080':
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
    source => $private ? {
      true  => $::local_subnet,
      false => undef,
    }
  }
}
class dtg::firewall::portforward ($src,$dest,$private) inherits dtg::firewall::default {
  firewall { "020 redirect ${src} to ${dest}":
    dport   => $src,
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => $dest,
  }
  firewall { "020 redirect ${src} to ${dest} localhost":
    dport       => $src,
    table       => 'nat',
    chain       => 'OUTPUT',
    jump        => 'REDIRECT',
    toports     => $dest,
    destination => '127.0.0.1/8',
  }
  firewall { "020 accept on ${dest}":
    proto  => 'tcp',
    dport  => $dest,
    action => 'accept',
    source => $private ? {
      true  => $::local_subnet,
      false => undef,
    }
  }
}

define dtg::firewall::nfs ($source, $source_name, $portmapper_port, $nfs_port, $lockd_tcpport, $lockd_udpport, $mountd_port, $rquotad_port, $statd_port) {
  firewall { "030-nfs accept tcp ${portmapper_port} (sunrpc) from ${source_name}":
    proto  => 'tcp',
    dport  => $portmapper_port,
    source => $source,
    action => 'accept',
  }
  firewall { "031-nfs accept udp ${portmapper_port} (sunrpc) from ${source_name}":
    proto  => 'udp',
    dport  => $portmapper_port,
    source => $source,
    action => 'accept',
  }
  firewall { "032-nfs accept tcp ${nfs_port} (nfs) from ${source_name}":
    proto  => 'tcp',
    dport  => $nfs_port,
    source => $source,
    action => 'accept',
  }
  firewall { "033-nfs accept tcp ${lockd_tcpport} (lockd) from ${source_name}":
    proto  => 'tcp',
    dport  => $lockd_tcpport,
    source => $source,
    action => 'accept',
  }
  firewall { "034-nfs accept udp ${lockd_udpport} (lockd) from ${source_name}":
    proto  => 'udp',
    dport  => $lockd_udpport,
    source => $source,
    action => 'accept',
  }
  firewall { "035-nfs accept tcp ${mountd_port} (mountd) from ${source_name}":
    proto  => 'tcp',
    dport  => $mountd_port,
    source => $source,
    action => 'accept',
  }
  firewall { "036-nfs accept udp ${mountd_port} (mountd) from ${source_name}":
    proto  => 'udp',
    dport  => $mountd_port,
    source => $source,
    action => 'accept',
  }
  firewall { "037-nfs accept tcp ${rquotad_port} (rquotad) from ${source_name}":
    proto  => 'tcp',
    dport  => $rquotad_port,
    source => $source,
    action => 'accept',
  }
  firewall { "038-nfs accept udp ${rquotad_port} (rquotad) from ${source_name}":
    proto  => 'udp',
    dport  => $rquotad_port,
    source => $source,
    action => 'accept',
  }
  firewall { "039-nfs accept tcp ${statd_port} (statd) from ${source_name}":
    proto  => 'tcp',
    dport  => $statd_port,
    source => $source,
    action => 'accept',
  }
  firewall { "039-nfs accept udp ${statd_port} (statd) from ${source_name}":
    proto  => 'udp',
    dport  => $statd_port,
    source => $source,
    action => 'accept',
  }
}

class dtg::firewall::avahi inherits dtg::firewall::default {
  firewall { '040-build accept avahi udp 5353':
    proto  => 'udp',
    dport  => 5353,
    action => 'accept',
  }
}


# hadoop related nodes, probably should do the required ports only (for yarn)
class dtg::firewall::hadoopcluster inherits dtg::firewall::default {

    firewall { '001 accept all sa497-crunch-0.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-0.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497-crunch-1.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-1.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497-crunch-2.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-2.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497-crunch-3.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-3.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all vm-sr-nile0.cl.cam.ac.uk':
        action => 'accept',
        source => 'vm-sr-nile0.cl.cam.ac.uk',
    }

    firewall { '001 accept all vm-sr-nile1.cl.cam.ac.uk':
        action => 'accept',
        source => 'vm-sr-nile1.cl.cam.ac.uk',
    }

    firewall { '001 accept all vm-sr-nile2.cl.cam.ac.uk':
        action => 'accept',
        source => 'vm-sr-nile2.cl.cam.ac.uk',
    }

    #not sure why it doesnt accept anya.ad.cl.cam.ac.uk by name
        firewall { '001 accept all 128.232.29.5':
        action => 'accept',
        source => '128.232.29.5',
    }

    firewall { '001 accept all africa01.cl.cam.ac.uk':
        action => 'accept',
        source => 'africa01.cl.cam.ac.uk',
    }

}

# The last rule which does the dropping
class dtg::firewall::post inherits dtg::firewall::default {
  firewall { '999 drop all':
    ensure => absent,
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
  firewall { '999 reject all':
    proto  => 'all',
    action => 'reject',
    before => undef,
    reject => 'icmp-admin-prohibited',
  }
}
