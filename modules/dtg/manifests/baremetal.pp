class dtg::baremetal {
  package {'ipmitool':
    ensure  => installed,
  }

  # Setup serial console.
  file {'/etc/default/grub':
    ensure => file,
    source => 'puppet:///modules/dtg/grub',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  exec { "update-grub":
    subscribe   => File["/etc/default/grub"],
    refreshonly => true
    }
  
}

