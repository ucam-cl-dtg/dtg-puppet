class dtg::zfs {
  class {'dtg::zfs::repos': stage => 'repos'}
  package {'ubuntu-zfs':
    ensure => present,
    require => Apt::Ppa['ppa:zfs-native/stable'],
  }
}

class dtg::zfs::repos {
  # ZFS is not in main repos due to licensing restrictions
  apt::ppa {'ppa:zfs-native/stable': }
}
