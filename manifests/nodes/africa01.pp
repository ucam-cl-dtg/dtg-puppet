node 'africa01.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::nfs'

  class { 'dtg::bonding': address => '128.232.23.175'}

  class {'dtg::zfs': }

  $pool_name = 'data-pool0'

  dtg::zfs::fs{'datashare':
    pool_name  => $pool_name,
    fs_name    => 'datashare',
    share_opts => 'ro=@vm-sr-nile0.cl.cam.ac.uk,ro=@vm-sr-nile1.cl.cam.ac.uk,async',
  }

  # Test FS so that we can monitor africa01 over NFS
  dtg::zfs::fs{'test':
    pool_name  => $pool_name,
    fs_name    => 'test',
    share_opts => 'ro=@128.232.20.0/22,async',
  }

  # Backups
  # We take backups of various servers onto nas01
  # these are run as low priority cron jobs
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


  # CCCC
  # Mount archive.cl.cam.ac.uk
  file {'/etc/auto.mnt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'archive-cccc   archive.cl.cam.ac.uk:/export/cccc',
  } ->
  file_line {'mount remote filesystems':
    line    => '/mnt   /etc/auto.mnt',
    path    => '/etc/auto.master',
    require => Package['autofs'],
  }

  file {'/home/cccc-backup/.ssh/':
    ensure => directory,
    owner  => 'cccc-backup',
    group  => 'cccc-backup',
    mode   => '0700',
  } ->
  ssh_authorized_key {'cccc-backup key 3':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDOb30ukReiQXDipoNG/UiqQPxymjt8qwiWxZl2yfguLf7CgyEaamTFYmQfoeeqWAC79HXB6E49+JoYJkSC0AcK9wOu1PqjoLgzyWbkn6Mb0woBLziLbDlRktB0wX3o+TeQz4juVRaPHwoRC2knXQhR6LIQmhUIx5b0FBu88IVte53CXJxYaTPMEORqgP8AzOReu6KPvgtyXNkMCtxJSqbNdu5ISrgOmddrDtigW+vhFY/0sFv1Ab/++UIm1FaRcQWTEIOlEaoXUstrLeWPa/CE85FJWvDMMuPDLVLD0Pqpnj3qGg5eGHDrw6HSjS4tEN3gO/V9Fx7nENb6tZ/nfXo2EdFXvAWtBWAtI4HXoumLEJTkpAV3OsMJtTzAH47vr0ullg+58md/cAFp/tS+ZgCy9T1Y++klD/r8HMf43WTz8F2GHz8XXnsnYuHAbVYs5ztht8vECcv6vkxQDqk2YLOshyrEfNb3BOSn7EpHEwifM5FKovVi7fslKKkHLtj7KoehuYGqEOqttUHpb7VW7mFRDLg1kbyWs+MbRg8Duez1OGfq9zTxR9figzaJuamvUDKM4J532h0+4Wlb3C5Aeu+0Yv2e0YhYWjIkJtxWvLh5+AS8/AYzMJpTbXQed6E9qZTyHNW3HuFnqBhiVguVoUpked2vjJFewoA5Tj8bna26yw==',
    user   => 'cccc-backup',
    type   => 'ssh-rsa',
  } ->
  ssh_authorized_key {'cccc-backup key 4':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQD0UfVs3Qwj2QTm0CKWlgiCS5EJcWFLtCrHXXr2U8kkpPA6RYpz2K/yv6b6j8W18qQKZj9MxmgZQeFEeoSKL0BfJs2vVLn8DY3z+23SiehvVQeWpzJnYOGcZAs7jjfAC9u3hE4VCGI23zik4A492EnybjRtifHfyhOExNXWmL+MmLGNaDihoSQhQI2pVnuOpAhOLp9n9xqBSluR0sDh0Y66osEKatyb3hcvK0vZOkh11BetDZXz3Bt31iSZVvuKwg4MeS+J++QZkol3Kd01dhnRJZ17XakqU6mdbS6S22kxwN57wjYmAUEwuCOe8NqyEjioNRd54b9fsxHlK9HhaneW0EurSCs2X88Da9je5cFGaIrbaJIskYW06clXosnmzzn4rs60dm/tO7TGO//J7Xlh8+Og+jurZXM2wEsnGMokXsuobw6jYRAumCBG9a6HakakSTcMPvF2QmilFYGUpttjXpOJPxhVwtNtrtbfvuIbDoYZ1C1NCyXwUzDvZLHlaMfBtf7HCZhz5W7bIF/Poqj7EfvtQBQrUblTqdegFQp20QxAta9FBiYhr8A87ZD1sfFea3kcMnnnlKglICVck5xkfhIiZwFkSNiBRLvmqRkW87hSF24hoWvws9O3GCD0ENc8lwarwd7beBnUnB2jaUUel1n8kLoCAqpESopTFJvluQ==',
    user   => 'cccc-backup',
    type   => 'ssh-rsa',
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
  } ->
  cron {'mirror iplane daily':
    ensure      => present,
    user        => 'cccc-data',
    minute      => cron_minute('mirror iplane daily'),
    hour        => 14,
    weekday     => '*',
    environment => 'MAILTO=cccc-infra@cl.cam.ac.uk',
    command     => 'bash -c "cd /data-pool0/cccc/iplane-mirror && wget --recursive --level=2 --convert-links --timestamping --no-remove-listing --no-parent --domains=iplane.cs.washington.edu --wait=1 --limit-rate=5m --relative -e robots=off http://iplane.cs.washington.edu/data/iplane_logs/`date --date=yesterday --iso-8601 | sed \'s|-|/|g\'`/" > /dev/null',
  }

  dtg::zfs::fs{'cccc/internet-map':
    pool_name  => $pool_name,
    fs_name    => 'cccc/internet-map',
    share_opts => 'off',
    require    => Dtg::Zfs::Fs['cccc'],
  }

  # Install go development environment
  package{'golang':
    ensure => installed,
  }

  $packagelist = ['bison' , 'flex', 'autoconf' , 'pkg-config',
                  'libpcap-dev' , 'mountall' , 'liblz4-tool', 'autofs']
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
