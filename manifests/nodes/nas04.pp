node 'nas04.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'nfs::server'

  class {'dtg::zfs': }

  class {'zfs_auto_snapshot':
    pool_names => [ 'dtg-pool' ]
  }

  cron { 'zfs_weekly_scrub':
    command => 'zpool scrub dtg-pool0',
    user    => 'root',
    minute  => 0,
    hour    => 0,
    weekday => 1,
  }

  $portmapper_port     = 111
  $nfs_port            = 2049
  $lockd_tcpport       = 32803
  $lockd_udpport       = 32769
  $mountd_port         = 892
  $rquotad_port        = 875
  $statd_port          = 662
  $statd_outgoing_port = 2020

  augeas { "nfs-kernel-server":
    context => "/files/etc/default/nfs-kernel-server",
    changes => [
                "set LOCKD_TCPPORT $lockd_tcpport",
                "set LOCKD_UDPPORT $lockd_udpport",
                "set MOUNTD_PORT $mountd_port",
                "set RQUOTAD_PORT $rquotad_port",
                "set STATD_PORT $statd_port",
                "set STATD_OUTGOING_PORT $statd_outgoing_port",
                ],
    notify => Service['nfs-kernel-server']
  }
  ->
  firewall { "030-nfs accept tcp $portmapper_port (sunrpc) from dtg":
    proto   => 'tcp',
    dport   => $portmapper_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "031-nfs accept udp $portmapper_port (sunrpc) from dtg":
    proto   => 'udp',
    dport   => $portmapper_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "032-nfs accept tcp $nfs_port (nfs) from dtg":
    proto   => 'tcp',
    dport   => $nfs_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "033-nfs accept tcp $lockd_tcpport (lockd) from dtg":
    proto   => 'tcp',
    dport   => $lockd_tcpport,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "034-nfs accept udp $lockd_udpport (lockd) from dtg":
    proto   => 'udp',
    dport   => $lockd_udpport,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "035-nfs accept tcp $mountd_port (mountd) from dtg":
    proto   => 'tcp',
    dport   => $mountd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "036-nfs accept udp $mountd_port (mountd) from dtg":
    proto   => 'udp',
    dport   => $mountd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "037-nfs accept tcp $rquotad_port (rquotad) from dtg":
    proto   => 'tcp',
    dport   => $rquotad_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "038-nfs accept udp $rquotad_port (rquotad) from dtg":
    proto   => 'udp',
    dport   => $rquotad_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "039-nfs accept tcp $statd_port (statd) from dtg":
    proto   => 'tcp',
    dport   => $statd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "039-nfs accept udp $statd_port (statd) from dtg":
    proto   => 'udp',
    dport   => $statd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'nas04':
    parents    => '',
    address    => 'nas04.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'nas04': }
}
