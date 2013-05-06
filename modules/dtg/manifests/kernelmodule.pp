define dtg::kernelmodule::add()
{  
  exec { "save_module_${name}":
    command => "/bin/echo '${name}' >> /etc/modules",
    unless => "/bin/grep -qFx '${name}' /etc/modules"
  }
  exec { "modprobe_module_${name}":
    command => "/sbin/modprobe ${name}",
    unless => "/bin/grep -q '^${name} ' /proc/modules"
  }
}
