class dtg::autologin {
  # Autologin as root

  file{'/etc/systemd/system/serial-getty@hvc0.service.d/':
    ensure => 'directory',
  }
  ->
  file{'/etc/systemd/system/serial-getty@hvc0.service.d/autologin.conf':
    ensure => file,
    source => 'puppet:///modules/dtg/autologin.conf',
    owner  => 'root',
    group  => 'root',
    mode   => 'u+rw,go+r',
  }
}
