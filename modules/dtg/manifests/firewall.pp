#iptables firewalling for nodes

class dtg::firewall($ssh_source, $interfacefile = '/etc/network/interfaces') inherits dtg::firewall::default {
  exec { 'persist-firewall':
    command     => '/sbin/iptables-save > /etc/iptables.rules',
    refreshonly => true,
  }

  file { '/etc/network/if-pre-up.d/loadiptables':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/preup-loadiptables',
  }
  
  # Purge unmanaged firewall resources
  #
  # This will clear any existing rules, and make sure that only rules
  # defined in puppet exist on the machine
#  resources { "firewall":
#    purge => true
#  }
  class {'dtg::firewall::pre':
    ssh_source => $ssh_source,
  }->
  class {'dtg::firewall::post':}
}
