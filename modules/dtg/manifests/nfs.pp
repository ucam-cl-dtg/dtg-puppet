
class dtg::nfs{

  include nfs::server

  $portmapper_port     = 111
  $nfs_port            = 2049
  $lockd_tcpport       = 32803
  $lockd_udpport       = 32769
  $mountd_port         = 892
  $rquotad_port        = 875
  $statd_port          = 662
  $statd_outgoing_port = 2020

  augeas { 'nfs-kernel-server':
     context => '/files/etc/default/nfs-kernel-server',
     changes => [
         "set LOCKD_TCPPORT ${lockd_tcpport}",
         "set LOCKD_UDPPORT ${lockd_udpport}",
         "set MOUNTD_PORT ${mountd_port}",
         "set RQUOTAD_PORT ${rquotad_port}",
         "set STATD_PORT ${statd_port}",
         "set STATD_OUTGOING_PORT ${statd_outgoing_port}",
         "set RPCMOUNTDOPTS \"'--manage-gids --port ${mountd_port}'\"",
     ],
     notify  => Service['nfs-kernel-server']
  }
}

define dtg::nfs::firewall($source) {
  dtg::firewall::nfs {$name: #TODO all the variables are blank
     source          => $source,
     source_name     => "nfs access from ${name}",
     portmapper_port => $dtg::nfs::portmapper_port,
     nfs_port        => $dtg::nfs::nfs_port,
     lockd_tcpport   => $dtg::nfs::lockd_tcpport,
     lockd_udpport   => $dtg::nfs::lockd_udpport,
     mountd_port     => $dtg::nfs::mountd_port,
     rquotad_port    => $dtg::nfs::rquotad_port,
     statd_port      => $dtg::nfs::statd_port,
  }
}
