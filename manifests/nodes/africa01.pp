node 'africa01.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::nfs'

  class { 'dtg::bonding': address => '128.232.23.175'}

  class { 'dtg::firewall::hadoopcluster': }

  class {'dtg::zfs': }

  class {'dtg::firewall::publichttp':}
  ->
  firewall {'060 accept all 8080':
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
  }

  $pool_name = 'data-pool0'

  dtg::zfs::fs{'datashare':
    pool_name  => $pool_name,
    fs_name    => 'datashare',
    share_opts => 'ro=@vm-sr-nile0.cl.cam.ac.uk,ro=@vm-sr-nile1.cl.cam.ac.uk,ro=@wright.cl.cam.ac.uk,ro=@airwolf.cl.cam.ac.uk,ro=@128.232.29.5,async',
  }

  # Test FS so that we can monitor africa01 over NFS
  dtg::zfs::fs{'test':
    pool_name  => $pool_name,
    fs_name    => 'test',
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
    directory => "/${pool_name}/backups",
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

  # Device Analyzer
  dtg::nfs::firewall {'deviceanalyzer':
    source          => $::deviceanalyzer_ip,
  }

  dtg::zfs::fs{'deviceanalyzer':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer',
    share_opts => 'rw=@deviceanalyzer.dtg.cl.cam.ac.uk,async',
  }->
  file {"/${pool_name}/deviceanalyzer":
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => 'ug=rwx',
  }

  dtg::zfs::fs{'deviceanalyzer-datadivider':
    pool_name  => $pool_name,
    fs_name    => 'deviceanalyzer-datadivider',
    share_opts => 'rw=@dh526-datadivider.dtg.cl.cam.ac.uk,async',
  }->
  file {"/${pool_name}/deviceanalyzer-datadivider":
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => 'ug=rwx',
  }


  # CCCC Data
  dtg::zfs::fs{'cccc':
    pool_name  => $pool_name,
    fs_name    => 'cccc',
    share_opts => 'off',
  } ->
  dtg::zfs::fs{'cccc/iplane-mirror':
    pool_name  => $pool_name,
    fs_name    => 'cccc/iplane-mirror',
    share_opts => 'off',
  } ->
  file {"/${pool_name}/cccc/iplane-mirror":
    ensure => directory,
    owner  => 'cccc-data',
    group  => 'cccc-data',
    mode   => 'ug+rwx',
  }
  cron {"mirror iplane daily":
    ensure      => present,
    user        => 'cccc-data',
    minute      => cron_minute("mirror iplane daily"),
    hour        => 14,
    weekday     => "*",
    environment => "MAILTO=cccc-infra@cl.cam.ac.uk",
    command     => 'bash -c "cd /data-pool0/cccc/iplane-mirror && wget --recursive --level=2 --convert-links --timestamping --no-remove-listing --no-parent --domains=iplane.cs.washington.edu --wait=1 --limit-rate=5m --relative -e robots=off http://iplane.cs.washington.edu/data/iplane_logs/`date --date=yesterday --iso-8601 | sed \'s|-|/|g\'`" > /dev/null',
  }

  User<|title == sa497 |> { groups +>[ 'adm' ]}

  $packagelist = ['bison' , 'flex', 'autoconf' , 'pkg-config', 'libpcap-dev' , 'mountall' , 'liblz4-tool']
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
  nagios::monitor { 'africa01-bmc':
    parents    => 'se18-r8-sw1',
    address    => 'africa01-bmc.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'bmcs' ],
  }

  munin::gatherer::async_node { 'africa01': }
}
