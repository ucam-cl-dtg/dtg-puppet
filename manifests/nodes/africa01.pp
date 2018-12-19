node 'africa01.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  include 'dtg::nfs'

  class { 'dtg::bonding': address => '128.232.23.175'}

  $pool_name = 'data-pool0'

  class {'dtg::zfs':
    zfs_poolname => $pool_name,
  }

  dtg::zfs::fs{'datashare':
    pool_name  => $pool_name,
    fs_name    => 'datashare',
    share_opts => 'off',
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

  file {'/home/cccc-backup/':
    ensure => directory,
    owner  => 'cccc-backup',
    group  => 'cccc-backup',
    mode   => '0750',
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
  } ->
  ssh_authorized_key {'cccc-backup key 5':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDfaRzAiKPVAg7X35OWr50mSDGJMh75rCn51XynGLyEcUppcBsupWzU4rm44k/VFssVySi/P+uJOAF9YjB/9p4fZxqmRyoG65MiymA9SxbU4Q3nZ5Cp9jVPE1iLErcjqqo544dLDvJU94C0ymvxwgiEFLBRv+pwseTzcwS0QH4+rEfyKZIOxYoIc5Q7mf7H3xozfmzSXlGkR5cjvdNTT5+2p7/IyFudnBms08mGEMJKMYvJrl3iNTlBKa3tEeehlaeZIVRikl+7NO50c+Gd/5Cbq3LR0BQPF84pAg6qqqZEQvl85VugR/IqUfFzZal0dxrAAKmf0HzYuYVholWHp+4vVsty/mfJ/LAFU3kYlIZsAGr+ty/9hV75dTdjZ+QutT2pj5jd+T0ihUDNbN/b8YWh7woGYXVEAE8ep+wKckYNZvkG7ZVcguIDctoGj1OPF48LtCSGXFtSpVQSx0CrhYh8EUU7oKUSQD2RPx7OLsCokRtEuHJiUmCC84s+8//iG/DwFp3pquib+PtsYZDDM2ogdOGsngJZETR0yxbyy/9HFo6nfkvVIJGYuU+lNBPr9/OKjZLewhR7p0IiUYsaqnlgjUAwxBaqWjmpbJHqMsi1Kur+SrAf2x2SggYEt0Dc4NBvB2o1aZGYCf3bltuTYzCyda2MWW3OuyUSP/XojQGnew==',
    user   => 'cccc-backup',
    type   => 'ssh-rsa',
  } ->
  ssh_authorized_key {'cccc-backup key 6':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQC51kOxW4YH1fSSB3g4X8yaLXe3EuSDi0xU63dL1lXyLg6U98xAcqVC7MdwTsM60XJPmtOtt0Cs0B3vdIblgCSysbhl4f4odz4EhAC519onQDP8E7kHrCW3i4+311ey+1JwONmTYd2ZrVlX6ujBrUG2yNKSD5JgVZiO3wTTj4ggnhDdd+hW8IbsJDHvLYV2U6rYDYMkQVbmDOQMq2PhpYNF/Ei1p/xlcfjm9Ce4eDyAjs2+aP0bly4Ix10YSHSj05gDl7MI2Qbs59zpJk9DrHl0apo+IdIKL0rr6cCz9NsavSfaTMeprtL57liIE42dHVn/fuYGGFY3qpb8r45Uoez/cxEcjvMhg67WQQLBTfuz2PPS8rlw6qwBL883f39rzE0BZrU9Ve74fpYdTfZF9Xc2m/tu9pWmsVOFGwMx+U6ndCJANGUGzp/AiZ28CdLpuNDR8PR1eS/gwksqbJkxK3Hfb0YqQCEbUJhouVQS0OxSR05hLsKrN+Kt0GgyNDIj7d5Fg3IaHset4WeP3Kd1abpyHUE/8n2wf1l2BJ8w4Dv7GkLYXvZUTmvV6/P7XyZcMqXzt6ItITrImWNjFo1X/NLSwWe4U3dzmp21DnodWkjzyTESt9P2ckbh9ZeRxxVgEcxDtq+pXgvBiy26YY3sAmH/gS6Gi867AKMF2Oqe6G0ePw==',
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

  # Postgresql keeps getting restarted halfway through the data transfer so turn off the automatic restarts for the moment
  file {'/etc/default/postupdate-service-restart':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'ACTION=false',
  }

  dtg::zfs::fs{'cccc/postgresql':
    pool_name         => $pool_name,
    fs_name           => 'cccc/postgresql',
    share_opts        => 'off',
    # Extra options set per http://open-zfs.org/wiki/Performance_tuning#PostgreSQL
    extra_opts_string => '-o recordsize=8K -o logbias=throughput',
    require           => Dtg::Zfs::Fs['cccc'],
  }

  dtg::zfs::fs{'postgresql':
    pool_name         => $pool_name,
    fs_name           => 'postgresql',
    share_opts        => 'off',
    # Extra options set per http://open-zfs.org/wiki/Performance_tuning#PostgreSQL
    extra_opts_string => '-o recordsize=8K',
  }

  class { 'postgresql::globals':
    version      => '9.5',
    datadir      => "/${pool_name}/postgresql/",
    needs_initdb => true,
    require      => Dtg::Zfs::Fs['postgresql'],
  }
  ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '127.0.0.1/32',
    listen_addresses           => '*',
    ipv4acls                   => ['local all all peer'],
  }
  # Performance tuning for higher memory usage
  postgresql::server::config_entry{'max_wal_size':
    ensure => present,
    value  => '10GB',
  }
  postgresql::server::config_entry{'shared_buffers':
    ensure => present,
    value  => '1GB',
  }
  postgresql::server::config_entry{'temp_buffers':
    ensure => present,
    value  => '64MB',
  }
  postgresql::server::config_entry{'work_mem':
    ensure => present,
    value  => '1GB',
  }
  postgresql::server::config_entry{'maintenance_work_mem':
    ensure => present,
    value  => '2GB',
  }
  postgresql::server::config_entry{'effective_io_concurrency':
    ensure => present,
    value  => '4',
  }
  postgresql::server::tablespace{'cccc':
    location => "/${pool_name}/cccc/postgresql/",
    require  => [Class['postgresql::server'], Dtg::Zfs::Fs['cccc/postgresql']],
  } ->
  postgresql::server::db{'mirai':
    user       => 'cccc-mirai',
    password   => 'mirai',
    encoding   => 'UTF-8',
    tablespace => 'cccc',
  } ->
  postgresql::server::extension{'ip4r':
    ensure       => present,
    package_name => 'postgresql-9.5-ip4r',
    database     => 'mirai',
  }
  # Creating a home directory for the postgresql user for the database
  # This is so that automated processes can connect to load data into the database
  file {'/home/cccc-mirai/':
    ensure => directory,
    owner  => 'cccc-mirai',
    group  => 'cccc-mirai',
    mode   => '0750',
  }
  file {'/home/cccc-mirai/.ssh/':
    ensure => directory,
    owner  => 'cccc-mirai',
    group  => 'cccc-mirai',
    mode   => '0700',
  } ->
  # TODO(drt24) add a command restriction so that this can only be used to load data
  #             into the database.
  ssh_authorized_key {'cccc-mirai':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDbRwo2I5AU9nlJdRGJzuRXV/TAWqzyUfwcrpxvbQs2FL3QwcXrEi8BFAf9PjncNhWb4gJql4l9+fttKOn0+DFG/rWQqiCk9Uj/gSDLr1O01ZgsxnL67FubCy1Q26KFMedmCxvFnvKxQP4NX4YSkVXr6qJg5iHr9bRfSsebaoVlrQC263Tl+KFrvg80JpLGpZcGOaAZWq+WR/GOjvDfsKn4rjU3WRrYns04rG5RhcEyuRvXxfW4Q3FD59Yyc4f0ukC/mXxyuX2BPAUHaAU6+ttL1acLLfpwqrWjQfdn+1wkx4W5z45oA9uYIfB7C4j/qBDE/1EeGOUzJRd5XraFgT5fQkuC6L99QHC+VINxkbqokUt6aGDC6HXFKZRLxzOMZHGTZpy+sj+JZNrdyokRMGTJHGGWlOzeM8tzYJArEOfZpApWERcxmxUtebV2hWuyeizUyoixH2iV+kFeol+e8VMVC3meX3JYftL1HJ1CqyT4yzO2JIj4XDcLaATpczc4NssP6M+Zog91rYMDwH9t+GAm52L8sh4+l1rbb9aXyxd9JLri3zBKTKUfBGzEUd9En578UXa7tpfb1gDpLHrRU94JlmEqJuhoGEBR7XsL/8nkN13y4F1uh78X77tuaEYYCG+5ccYO2UjmcQStXtCqdOQlpza0bAkmU+7KFoaSR1HvMw==',
    user   => 'cccc-mirai',
    type   => 'ssh-rsa',
  }

  $packagelist = ['golang', 'bison' , 'flex', 'autoconf' , 'pkg-config',
                  'libpcap-dev' , 'mountall' , 'liblz4-tool', 'autofs',
                  'socat', 'libdbd-pg-perl']
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
    parents    => '',
    address    => 'africa01-bmc.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'bmcs' ],
  }

  munin::gatherer::async_node { 'africa01': }
}
