node 'nas04.dtg.cl.cam.ac.uk' {
  include 'nfs::server'

  class { 'dtg::minimal': adm_sudoers => false}

  $pool_name = 'dtg-pool0'
  $cl_share = "rw=@${local_subnet}"
  $dtg_share = "rw=@${dtg_subnet},rw=@${desktop_ips}"
  $secgrp_subnet = '128.232.18.0/24'
  $pig20_ip = '128.232.64.63'

  class {'dtg::zfs': }

  class {'zfs_auto_snapshot':
    pool_names => [ $pool_name ]
  }


  dtg::zfs::fs{'vms':
    pool_name  => $pool_name,
    fs_name    => 'vms',
    share_opts => 'rw=@128.232.20.18,rw=@128.232.20.20,rw=@128.232.20.22,rw=@128.232.20.24,rw=@128.232.20.26',
  }

  dtg::zfs::fs{'shin-backup':
    pool_name  => $pool_name,
    fs_name    => 'shin-backup',
    share_opts => "rw=@shin.cl.cam.ac.uk",
  }

  dtg::zfs::fs{'abbot-archive':
    pool_name  => $pool_name,
    fs_name    => 'abbot-archive',
    share_opts => $dtg_share,
  }

  dtg::zfs::fs{'time':
    pool_name  => $pool_name,
    fs_name    => 'time',
    share_opts => $dtg_share,
  }


  dtg::zfs::fs{'deviceanalyzer':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer',
    share_opts => "$dtg_share,rw=@$deviceanalyzer_ip,ro=@$secgrp_subnet,ro=@$pig20_ip",
  }

  dtg::zfs::fs{ 'deviceanalyzer-nas02-backup':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer-nas02-backup',
    share_opts => 'off',
  }

  # Mount nas02 in order to back it up.
  file {'/mnt/nas02':
    ensure => directory,
    owner  => 'root',
  }
  file {'/mnt/nas02/deviceanalyzer':
    ensure => directory,
    owner  => 'root',
  } ->
  package {'autofs':
    ensure => present,
  } ->
  file {'/etc/auto.nas02':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => 'a=r',
    content => 'deviceanalyzer  -ro  nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer',
  } ->
  file_line {'mount nas02':
    line => '/mnt/nas02   /etc/auto.nas02',
    path => '/etc/auto.master',
  }

  cron { 'deviceanalyzer-nas02-backup':
    ensure  => present,
    command => "nice rsync -a --delete /mnt/nas02/deviceanalyzer /$pool_name/deviceanalyzer-nas02-backup",
    user    => 'root',
    minute  => cron_minute("deviceanalyzer-nas02-backup"),
    require => [Dtg::Zfs::Fs['deviceanalyzer-nas02-backup'], File_line['mount nas02']],
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

  augeas { "nfs-kernel-server":
    context => "/files/etc/default/nfs-kernel-server",
    changes => [
                "set LOCKD_TCPPORT $lockd_tcpport",
                "set LOCKD_UDPPORT $lockd_udpport",
                "set MOUNTD_PORT $mountd_port",
                "set RQUOTAD_PORT $rquotad_port",
                "set STATD_PORT $statd_port",
                "set STATD_OUTGOING_PORT $statd_outgoing_port",
                "set RPCMOUNTDOPTS \"'--manage-gids --port $mountd_port'\"",
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

  augeas { "default_grub":
    context => "/files/etc/default/grub",
    changes => [
                "set GRUB_RECORDFAIL_TIMEOUT 2",
                "set GRUB_HIDDEN_TIMEOUT 0",
                "set GRUB_TIMEOUT 2"
                ],
  }

  file {"/etc/update-motd.d/10-help-text":
    ensure => absent
  }
  
  file {"/etc/update-motd.d/50-landscape-sysinfo":
    ensure => absent
  }
  
  file{"/etc/update-motd.d/20-disk-info":
    source => 'puppet:///modules/dtg/motd/nas04-disk-info'
  }
  
  class { "smartd": 
    mail_to => "dtg-infra@cl.cam.ac.uk",
    service_name => 'smartmontools',
    devicescan_options => "-m dtg-infra@cl.cam.ac.uk -M daily"
  }

  file {'/etc/default/postupdate-service-restart':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => 'a=r',
    content => 'ACTION=false',
  }
}

if ( $::monitor ) {
  nagios::monitor { 'nas04':
    parents    => '',
    address    => 'nas04.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'nas04': }
}
