node 'africa01.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::nfs'

  class { 'dtg::firewall::hadoopcluster': }

  class {'dtg::zfs': }

  $pool_name = 'data-pool0'

  dtg::zfs::fs{'datashare':
    pool_name => $pool_name,
    fs_name => 'datashare',
    share_opts => 'ro=@vm-sr-nile0.cl.cam.ac.uk,ro=@vm-sr-nile1.cl.cam.ac.uk,ro=@wright.cl.cam.ac.uk,ro=@airwolf.cl.cam.ac.uk,ro=@128.232.29.5,async',
  }

  # Test FS so that we can monitor africa01 over NFS
  dtg::zfs::fs{'test':
    pool_name => $pool_name,
    fs_name => 'test',
    share_opts => 'ro=@128.232.20.0/22,async',
  }

  dtg::sudoers_group{ 'africa':
    group_name => 'africa',
  }

  cron { 'zfs_weekly_scrub':
    command => '/sbin/zpool scrub data-pool0',
    user    => 'root',
    minute  => 0,
    hour    => 0,
    weekday => 1,
  }

  dtg::nfs::firewall {'dtg':
    source          => '128.232.20.0/22',
  }

  dtg::nfs::firewall {'wright.cl.cam.ac.uk':
    source          => 'wright.cl.cam.ac.uk',
  }

  dtg::nfs::firewall {'airwolf.cl.cam.ac.uk':
    source          => 'airwolf.cl.cam.ac.uk',
  }

  dtg::nfs::firewall {'128.232.29.5':
    source          => '128.232.29.5',
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
    hostgroups => [ 'ssh-servers', 'nfs-servers' ],
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

