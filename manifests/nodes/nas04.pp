node 'nas04.dtg.cl.cam.ac.uk' {
  include 'nfs::server'

  class { 'dtg::minimal': adm_sudoers => false}

  $pool_name = 'dtg-pool0'
  $cl_share = "rw=@${local_subnet}"
  $desktop_share = join($desktop_ips, ',rw=@')
  $dtg_share = "rw=@${dtg_subnet},rw=@${desktop_share}"
  $secgrp_subnet = '128.232.18.0/24'
  $pig20_ip = '128.232.64.63'

  class {'dtg::zfs': }

  class {'zfs_auto_snapshot':
    fs_names => [ "${pool_name}/abbot-archive",
                  "${pool_name}/bayncore",
                  "${pool_name}/deviceanalyzer-nas02-backup",
                  "${pool_name}/shin-backup",
                  "${pool_name}/rscfl",
                  "${pool_name}/time",
                  "${pool_name}/vms",
                  ]
  }


  dtg::zfs::fs{'vms':
    pool_name  => $pool_name,
    fs_name    => 'vms',
    share_opts => 'rw=@128.232.20.18,rw=@128.232.20.20,rw=@128.232.20.22,rw=@128.232.20.24,rw=@128.232.20.26,async',
  }

  dtg::zfs::fs{'isos':
    pool_name  => $pool_name,
    fs_name    => 'isos',
    share_opts => "ro=@${dtg_subnet},async",
  }

  dtg::zfs::fs{'shin-backup':
    pool_name  => $pool_name,
    fs_name    => 'shin-backup',
    share_opts => 'rw=@shin.cl.cam.ac.uk,async',
  }

  dtg::zfs::fs{'nakedscientists':
    pool_name  => $pool_name,
    fs_name    => 'nakedscientists',
    share_opts => 'rw=@131.111.39.72,rw=@131.111.39.84,rw=@131.111.39.87,rw=@131.111.39.103,async',
  }

  dtg::zfs::fs{'abbot-archive':
    pool_name  => $pool_name,
    fs_name    => 'abbot-archive',
    share_opts => "$dtg_share,async",
  }

  dtg::zfs::fs{'time':
    pool_name  => $pool_name,
    fs_name    => 'time',
    share_opts => "$dtg_share,async",
  }


  dtg::zfs::fs{'deviceanalyzer':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer',
    share_opts => "${dtg_share},rw=@${deviceanalyzer_ip},ro=@${secgrp_subnet},ro=@${pig20_ip},async",
  }

  dtg::zfs::fs{'deviceanalyzer-datadivider':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer-datadivider',
    share_opts => "${dtg_share},rw=@${deviceanalyzer_ip},async",
  }

  dtg::zfs::fs{ 'deviceanalyzer-nas02-backup':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer-nas02-backup',
    share_opts => 'off',
  }

  $saluki_share = "rw=@128.232.98.206,@128.232.98.207"
  
  dtg::zfs::fs{ 'bayncore':
    pool_name  => $pool_name,
    fs_name    => 'bayncore',
    share_opts => "${dtg_share},${saluki_share},async",
  }
  

# Not using this method ATM

#   # Mount nas02 in order to back it up.

#   file {'/mnt/nas02':

#     ensure => directory,

#     owner  => 'root',

#   }

#   file {'/mnt/nas02/deviceanalyzer':

#     ensure => directory,

#     owner  => 'root',

#   } ->

#   package {'autofs':

#     ensure => present,

#   } ->

#   file {'/etc/auto.nas02':

#     ensure => file,

#     owner  => 'root',

#     group  => 'root',

#     mode   => 'a=r',

#     content => 'deviceanalyzer  -ro  nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer',

#   } ->

#   file_line {'mount nas02':

#     line => '/mnt/nas02   /etc/auto.nas02',

#     path => '/etc/auto.master',

#   }

  cron { 'deviceanalyzer-nas02-backup':
    ensure  => present,
    command => "pgrep -c rsync || nice -n 18 rsync -az --delete --rsync-path='/usr/syno/bin/rsync' nas04@nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer/ /${pool_name}/deviceanalyzer-nas02-backup",
    user    => 'root',
    minute  => cron_minute('deviceanalyzer-nas02-backup'),
    hour    => '1',
    require => [Dtg::Zfs::Fs['deviceanalyzer-nas02-backup']],
  }


  cron { 'zfs_weekly_scrub':
    command => '/sbin/zpool scrub dtg-pool0',
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
    #131.111.39.65 - 131.111.39.126 which covers the four IP addresses we need to let through
    source_name     => 'nakedscientists',
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
    parents    => 'se18-r8-sw1',
    address    => 'nas04.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'nas04-bmc':
    parents    => 'se18-r8-sw1',
    address    => 'nas04-bmc.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }

  munin::gatherer::configure_node { 'nas04': }
}
