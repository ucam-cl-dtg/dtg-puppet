node 'africa01.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'nfs::server'  

  class { 'dtg::firewall::hadoopcluster': }

  class {'dtg::zfs': }

  dtg::zfs::fs{'datashare':
    pool_name => 'data-pool0',
    fs_name => 'datashare',
    share_opts => "ro=@vm-sr-nile0.cl.cam.ac.uk,async",
  }


  cron { 'zfs_weekly_scrub':
    command => '/sbin/zpool scrub data-pool0',
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
  dtg::firewall::nfs {'nfs access from dtg':
     source          => '128.232.20.0/22',
     source_name     => 'dtg',
     portmapper_port => $portmapper_port,
     nfs_port        => $nfs_port,
     lockd_tcpport   => $lockd_tcpport,
     lockd_udpport   => $lockd_udpport,
     mountd_port     => $mountd_port,
     rquotad_port    => $rquotad_port,
     statd_port      => $statd_port,
  }


  User<|title == sa497 |> { groups +>[ 'adm' ]}

  class {'apt::source::megaraid':
    stage => "repos"
  }

  $packagelist = ['megacli', 'bison' , 'flex', 'autoconf' , 'pkg-config' , 'libglib2.0-dev', 'libpcap-dev' , 'mountall' , 'liblz4-tool']
  package {
	    $packagelist:
          ensure => installed
  }


}

if ( $::monitor ) {
  nagios::monitor { 'africa01':
    parents    => '',
    address    => 'africa01.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'africa01': }
}

class apt::source::megaraid {
    apt::source { 'megaraid':
    location => 'http://hwraid.le-vert.net/ubuntu',
    release => 'lucid',
    repos => 'main',
    key => {
        'id' => '6005210E23B3D3B4',
        'source' => 'http://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key',
        },
    }
}

