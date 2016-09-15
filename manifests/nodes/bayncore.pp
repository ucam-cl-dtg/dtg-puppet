
class bayncore::ssh_users{ # lint:ignore:autoloader_layout
  bayncore::ssh_user {'rogerphilp':
    real_name => 'Roger Philp (Bayncore)',
    uid       => 20000
  }

  bayncore::ssh_user {'manelfernandez':
    real_name => 'Manel Fernandez (Bayncore)',
    uid       => 20001,
  }

  bayncore::ssh_user {'francoisfayard':
    real_name => 'Francois Fayard (Bayncore)',
    uid       => 20004
  }

  bayncore::ssh_user {'bpwc2':
    ensure    => absent,
    real_name => 'Ben Catterall (Undergraduate)',
    uid       => 231340,
  }

  bayncore::ssh_user {'smj58':
    ensure    => absent,
    real_name => 'Siddhant Jayakumar (Undergraduate)',
    uid       => 229858,
  }

  bayncore::ssh_user {'sa614':
    real_name => 'Sam Ainsworth (PhD Student)',
    uid       => 3354,
  }

  bayncore::ssh_user {'jankostrassburg':
    real_name => 'Janko Strassburg (Bayncore)',
    uid       => 20005,
  }

  bayncore::ssh_user {'stephenblairchappell':
    real_name => 'Stephen Blair-Chappell (Bayncore)',
    uid       => 20006
  }

}

node /saluki(\d+)?/ {
  include 'dtg::minimal'

  include 'nfs::server'

  $packages = ['build-essential','linux-headers-generic','alien',
              'libstdc++6:i386','vnc4server','bridge-utils','libgtk2.0-0',
              'ubuntu-desktop','ubuntu-artwork']

  package{$packages:
    ensure => installed,
  }
  
  firewall { '050 accept all 10.0.0.0/8':
    action => 'accept',
    source => '10.0.0.0/8'
  }

  firewall { '051 nat 10.0.0.0/8':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => 'all',
    outiface => 'em1',
    source   => '10.0.0.0/8',
    table    => 'nat',
  }

  exec { 'ipforward':
    command => '/bin/echo 1 > /proc/sys/net/ipv4/ip_forward',
    unless  => '/bin/grep 1 /proc/sys/net/ipv4/ip_forward',
  }

  augeas { 'sysctl-ipforward':
    context => '/files/etc/sysctl.conf',
    changes => [
                'set net.ipv4.ip_forward 1'
                ],
  }
    
  class{ 'bayncore::setup': } -> class{ 'bayncore::ssh_users': }
}

node /naps-bayncore/ {
  include 'dtg::minimal'

  $packages = ['build-essential','libstdc++6:i386','vnc4server']
  
  class{ 'bayncore::setup': } -> class{ 'bayncore::ssh_users': }

  package{$packages:
    ensure => installed,
  }
  
}

if ( $::monitor ) {

  nagios::monitor { 'naps-bayncore':
    parents    => 'nas04',
    address    => 'naps-bayncore.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
  
  munin::gatherer::async_node { 'saluki1': }
  munin::gatherer::async_node { 'saluki2': }
}
