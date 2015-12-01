node 'africa01.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::nfs'

  class { 'dtg::bonding': address => '128.232.23.175'}

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

  # Backups
  # We take backups of various servers onto nas01 these are run as low priority cron jobs
  # and run as very restricted user.
  dtg::zfs::fs{'backups':
    pool_name  => $pool_name,
    fs_name    => 'backups',
    share_opts => 'off'
  } ->
  class { 'dtg::backup::host':
    directory => "/$pool_name/backups",
  }

  # Weather
  dtg::zfs::fs{'weather':
    pool_name => $pool_name,
    fs_name => 'weather',
    share_opts => 'rw=@weather.dtg.cl.cam.ac.uk,ro=@{::dtg_subnet},ro=@128.232.28.41,async',# 128.232.28.41 is Tien Han Chua's VM
  }

  user {'weather':
    ensure => 'present',
    uid => 501,
    gid => 'www-data',
  }

  file {"/$pool_name/weather":
    ensure => directory,
    owner => 'weather',
    group => 'www-data',
    mode => 'ug=rwx,o=rx',
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

