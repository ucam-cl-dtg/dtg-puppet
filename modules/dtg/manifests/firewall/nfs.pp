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
