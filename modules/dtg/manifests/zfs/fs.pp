define dtg::zfs::fs ($pool_name, $fs_name, $share_opts, $compress_opts='on') {
  exec { "zfs create ${pool_name}/${fs_name}":
    command => "sudo zfs create -o compression=${compress_opts} -o sharenfs=${share_opts} ${pool_name}/${fs_name}",
    onlyif  => "[  ! -d /${pool_name}/${fs_name} ]",
  }
  ->
  exec { "zfs set sharenfs ${pool_name}/${fs_name}":
    command => "sudo zfs set sharenfs=${share_opts} ${pool_name}/${fs_name}",
    onlyif  => "[ `sudo zfs get -H -o value sharenfs ${pool_name}/${fs_name}` != \"${share_opts}\" ]"
  }
}
