node 'nas04.dtg.cl.cam.ac.uk' {
  include 'nfs::server'

  class { 'dtg::minimal': adm_sudoers => false}

  $pool_name = 'dtg-pool0'

  $desktop_share = zfs_shareopts([],$desktop_ips_array,"rw=@${dtg_subnet}")
  $da_machines = ['jenkins-master.dtg.cl.cam.ac.uk',
                  'dac53.dtg.cl.cam.ac.uk',
                  'grapevine.cl.cam.ac.uk',
                  'earlybird.cl.cam.ac.uk',
                  'sak70-math.dtg.cl.cam.ac.uk',
                  'acr31-misc.dtg.cl.cam.ac.uk']

  # bonded nics
  dtg::kernelmodule::add{'bonding': }
  package{'ifenslave':
    ensure => installed
  }
  class { 'network::interfaces':
    interfaces => {
      'eth0'  => {
        'method'      => 'manual',
        'bond-master' => 'bond0',
      },
      'eth1'  => {
        'method'      => 'manual',
        'bond-master' => 'bond0',
      },
      'bond0' => {
        'method'          => 'static',
        'address'         => '128.232.20.60',
        'netmask'         => '255.255.252.0',
        'network'         => '128.232.20.0',
        'broadcast'       => '128.232.23.255',
        'gateway'         => '128.232.20.1',
        'dns-nameservers' => $::dns_name_servers,
        'dns-search'      => 'dtg.cl.cam.ac.uk',
        'bond-mode'       => '4',
        'bond-miimon'     => '100',
        'bond-lacp-rate'  => '1',
        'bond-slaves'     => 'eth0 eth1'
      }
    },
    auto       => ['eth0', 'eth1', 'bond0'],
  }


  class {'dtg::zfs': }

  class {'zfs_auto_snapshot':
    fs_names => [ "${pool_name}/deviceanalyzer-graphing",
                  "${pool_name}/rscfl",
                  "${pool_name}/vms"
                  ]
  }


  dtg::zfs::fs{'vms':
    pool_name  => $pool_name,
    fs_name    => 'vms',
    share_opts => zfs_shareopts([],['husky0.dtg.cl.cam.ac.uk',
                                    'husky1.dtg.cl.cam.ac.uk',
                                    'husky2.dtg.cl.cam.ac.uk',
                                    'husky3.dtg.cl.cam.ac.uk',
                                    'husky4.dtg.cl.cam.ac.uk'])
  }

  dtg::zfs::fs{'isos':
    pool_name  => $pool_name,
    fs_name    => 'isos',
    share_opts => zfs_shareopts([],[],"ro=@${dtg_subnet}"),
  }
  
  dtg::zfs::fs{'nakedscientists':
    pool_name  => $pool_name,
    fs_name    => 'nakedscientists',
    share_opts => zfs_shareopts([],['131.111.39.72',
                                    '131.111.39.84',
                                    '131.111.39.103',
                                    '131.111.61.37',
                                    '81.201.132.39',
                                    '81.201.132.24',
                                    '83.218.148.106']),
  }

  dtg::zfs::fs{'users':
    pool_name  => $pool_name,
    fs_name    => 'users',
    share_opts => 'off',
  }
  ->
  dtg::zfs::fs{'users/acr31':
    pool_name  => $pool_name,
    fs_name    => 'users/acr31',
    share_opts => zfs_shareopts([],['acr31-misc.dtg.cl.cam.ac.uk']),
  }

  dtg::zfs::fs{'archive':
    pool_name  => $pool_name,
    fs_name    => 'archive',
    share_opts => 'off',
  }
  ->
  dtg::zfs::fs{'archive/abbot-archive':
    pool_name  => $pool_name,
    fs_name    => 'archive/abbot-archive',
    share_opts => zfs_shareopts([],[],"ro=@${dtg_subnet}"),
  }
  ->
  dtg::zfs::fs{'archive/retired-git-repos':
    pool_name  => $pool_name,
    fs_name    => 'archive/retired-git-repos',
    share_opts => zfs_shareopts([],[],"ro=@${dtg_subnet}"),
  }
  ->
  dtg::zfs::fs{'archive/time':
    pool_name  => $pool_name,
    fs_name    => 'archive/time',
    share_opts => zfs_shareopts([],[],"ro=@${dtg_subnet}"),
  }

  dtg::zfs::fs{'deviceanalyzer-graphing':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer-graphing',
    share_opts => zfs_shareopts($da_machines,[],"ro=@${dtg_subnet}"),
  }

  dtg::zfs::fs{'datasets':
    pool_name  => $pool_name,
    fs_name    => 'datasets',
    share_opts => 'off',
  }
  ->
  dtg::zfs::fs{'datasets/rwandadataset':
    pool_name  => $pool_name,
    fs_name    => 'datasets/rwandadataset',
    share_opts => zfs_shareopts(['grapevine.cl.cam.ac.uk'], []),
  }
  ->
  dtg::zfs::fs{ 'datasets/caida-internet-traces-2014':
    pool_name  => $pool_name,
    fs_name    => 'datasets/caida-internet-traces-2014',
    share_opts => zfs_shareopts([],[],"ro=@${dtg_subnet}"),
  }
  ->
  dtg::zfs::fs{ 'datasets/acis-busdata':
    pool_name  => $pool_name,
    fs_name    => 'datasets/acis-busdata',
    share_opts => 'off',
  }
  ->
  dtg::zfs::fs{ 'datasets/batlogs':
    pool_name  => $pool_name,
    fs_name    => 'datasets/batlogs',
    share_opts => 'off',
  }
  ->
  dtg::zfs::fs{ 'datasets/50k-c':
    pool_name  => $pool_name,
    fs_name    => 'datasets/50k-c',
    share_opts => zfs_shareopts([],[],"ro=@${dtg_subnet}"),
  }

  dtg::zfs::fs{'backups':
    pool_name  => $pool_name,
    fs_name    => 'backups',
    share_opts => 'off'
  }
  ->
  dtg::zfs::fs{'backups/deviceanalyzer':
    pool_name  => $pool_name,
    fs_name    => 'backups/deviceanalyzer',
    share_opts => zfs_shareopts($da_machines, []),
  }
  ->
  class { 'dtg::backup::host':
    directory => "/${pool_name}/backups",
  }
  ->
  sudoers::allowed_command{ 'backup-zfs':
    command          => '/sbin/zfs',
    user             => 'backup',
    run_as           => 'root',
    require_password => false,
    comment          => 'Allow the backup user to use sudo for zfs',
  }
  
  cron { 'zfs_weekly_scrub':
    command => "/sbin/zpool scrub ${pool_name}",
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
    source          => $::local_subnet,
    source_name     => 'dtg',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }
  dtg::firewall::nfs {'nfs access from nakedscientists':
    source          => '131.111.39.64/26',
    #131.111.39.65 - 131.111.39.126
    #which covers the four IP addresses we need to let through
    source_name     => 'nakedscientists',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }
  dtg::firewall::nfs {'nfs access from nakedscientists medschl':
    source          => '131.111.61.37',
    source_name     => 'nakedscientists medschl',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }
  dtg::firewall::nfs {'nfs access from nakedscientists web main':
    source          => '81.201.132.39',
    source_name     => 'nakedscientists web main',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }
  dtg::firewall::nfs {'nfs access from nakedscientists web reserve':
    source          => '81.201.132.24',
    source_name     => 'nakedscientists web reserve',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }

  augeas { 'default_grub':
    context => '/files/etc/default/grub',
    changes => [
                'set GRUB_RECORDFAIL_TIMEOUT 2',
                'set GRUB_HIDDEN_TIMEOUT 0',
                'set GRUB_TIMEOUT 2'
                ],
  }

  file {'/etc/update-motd.d/10-help-text':
    ensure => absent
  }
  
  file {'/etc/update-motd.d/50-landscape-sysinfo':
    ensure => absent
  }
  
  file{'/etc/update-motd.d/20-disk-info':
    source => 'puppet:///modules/dtg/motd/nas04-disk-info'
  }
  
  class { 'smartd':
    mail_to            => 'dtg-infra@cl.cam.ac.uk',
    service_name       => 'smartmontools',
    devicescan_options => '-m dtg-infra@cl.cam.ac.uk -M daily'
  }

  package { 'scsitools':
    ensure => installed,
  }

  file {'/etc/default/postupdate-service-restart':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'ACTION=false',
  }
}

if ( $::monitor ) {
  nagios::monitor { 'nas04':
    parents    => '',
    address    => 'nas04.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'nfs-servers' ],
  }
  nagios::monitor { 'nas04-bmc':
    parents    => '',
    address    => 'nas04-bmc.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'bmcs' ],
  }

  munin::gatherer::async_node { 'nas04': }
}
