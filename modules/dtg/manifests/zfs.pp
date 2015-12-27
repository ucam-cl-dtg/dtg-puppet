
class dtg::zfs(
  $zfs_mount     = 'no',
  $zfs_unmount   = 'no',
  $zfs_share     = 'yes',
  $zfs_unshare   = 'no',
  $zfs_debug     = 'no',
  $zfs_debug_dmu = 'no',
  $zfs_sleep     = 0,
  ) {

  package {"linux-headers-generic":
    ensure => present,
  }

  package {'zfsutils-linux':
    ensure  => present,
  }

  file {'/etc/default/zfs':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => template('dtg/zfs/zfs.erb'),
  }

  # zfs includes this config file to let unpriviliged users run read only ZFS commands.
  # By default, it has the options disabled, so let's put that right.
  # Without doing this, munin cannot read zfs's state :-(

  file {'/etc/sudoers.d/zfs':
    ensure => file,
    owner  =>  'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/dtg/zfs/zfs-sudoers',
  }
  
  file {'/usr/share/munin/plugins/zpool_status':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/zfs/zpool_status'
  }

  file {'/usr/share/munin/plugins/zlist':
    ensure => file,
    owner  =>  'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/zfs/zlist',
  }

  file {'/usr/share/munin/plugins/zfs-filesystem-graph':
    ensure => file,
    owner  =>  'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/zfs/zfs-filesystem-graph',
  }

  file {'/usr/share/munin/plugins/zpool_iostat':
    ensure => file,
    owner  =>  'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/zfs/zpool_iostat',
  }

  file {'/etc/munin/plugins/zpool_status':
    ensure => link,
    target => '/usr/share/munin/plugins/zpool_status',
  }
  
  file {'/etc/munin/plugins/zlist':
    ensure => link,
    target => '/usr/share/munin/plugins/zlist',
  }

  #FIXME bug, this refers to dtg-pool0 which is only true on nas04
  file {'/etc/munin/plugins/zfs_fs_dtg-pool0':
    ensure => link,
    target => '/usr/share/munin/plugins/zfs-filesystem-graph',
  }

  file {'/etc/munin/plugins/zpool_iostat':
    ensure => link,
    target => '/usr/share/munin/plugins/zpool_iostat',
  }
}

define dtg::zfs::fs ($pool_name, $fs_name, $share_opts, $compress_opts='on') {
  exec { "zfs create ${pool_name}/${fs_name}":
    command => "sudo zfs create -o compression=${compress_opts} -o sharenfs=${share_opts} ${pool_name}/${fs_name}",
    onlyif  => "[  ! -d /${pool_name}/${fs_name} ]",
  }
}
