define bayncore_ssh_user($real_name,$uid) {
  $username = $title
  user { $username:
    ensure     => present,
    comment    => "${real_name} <${email}>",
    home       => "/home/${username}",
    shell      => '/bin/bash',
    groups     => [],
    uid        => $uid,
    membership => 'minimum',
    password   => '*',
  }
  ->
  group { $username:
    require => User[$username],
    gid     => $uid,
  }
}

define bayncore_setup() {

  exec { 'remount':
    command     => '/bin/mount -a',
    refreshonly => true,
  }

  package {['gfortran']:
    ensure => installed,
  }
  
  file {'/mnt/bayncore':
    ensure => directory,
  }
  ->
  file_line { 'mount nas04':
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/bayncore /mnt/bayncore nfs defaults 0 0',
    path   => '/etc/fstab',
    ensure => present,
    notify => Exec['remount'],
  }
  ->
  file_line { 'mount home':
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/bayncore/home /home nfs defaults 0 0',
    path   => '/etc/fstab',
    ensure => present,
    notify => Exec['remount'],
  }

  bayncore_ssh_user {'rogerphilp':
    real_name => 'Roger Philp (Bayncore)',
    uid       => 20000
  }

  bayncore_ssh_user {'manelfernandez':
    real_name => 'Manel Fernandez (Bayncore)',
    uid       => 20001,
  }

  bayncore_ssh_user {'richardpaul':
    real_name => 'Richard Paul (Bayncore)',
    uid       => 20002
  }

  bayncore_ssh_user {'francoisfayard':
    real_name => 'Francois Fayard (Bayncore)',
    uid       => 20004
  }

  bayncore_ssh_user {'bpwc2':
    real_name => 'Ben Catterall (Undergraduate)',
    uid       => 231340,
  }

  bayncore_ssh_user {'smj58':
    real_name => 'Siddhant Jayakumar (Undergraduate)',
    uid       => 229858,
  }

}

node /saluki(\d+)?/ {
  include 'dtg::minimal'

  include 'nfs::server'

  $packages = ['build-essential','linux-headers-generic','alien','libstdc++6:i386','vnc4server','bridge-utils','libgtk2.0-0','ubuntu-desktop','ubuntu-artwork']

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
    
  
  bayncore_setup { 'saluki-users': }
  
}

node /naps-bayncore/ {
  include 'dtg::minimal'

  $packages = ['build-essential','libstdc++6:i386','vnc4server']
  
  bayncore_setup { 'naps-bayncore': }

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
  
  munin::gatherer::configure_node { 'saluki1': }
  munin::gatherer::configure_node { 'saluki2': }
}
