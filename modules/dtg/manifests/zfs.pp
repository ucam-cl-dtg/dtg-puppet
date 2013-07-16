class dtg::zfs {
  class {'dtg::zfs::repos': stage => 'repos'}
  package {'ubuntu-zfs':
    ensure => present,
    require => Apt::Ppa['ppa:zfs-native/stable'],
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
}

class dtg::zfs::repos {
  # ZFS is not in main repos due to licensing restrictions
  apt::ppa {'ppa:zfs-native/stable': }
}
