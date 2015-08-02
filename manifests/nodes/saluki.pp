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
  ->
  file { "/home/${username}/":
    ensure  => directory,
    owner   => $username,
    group   => $username,
    mode    => '0755',
  }
  ->
  file {"/home/${username}/.ssh/":
    ensure => directory,
    owner => $username,
    group => $username,
    mode => '0700',
  }
  ->
  exec {"gen-${username}-sshkey":
    command => "sudo -H -u ${username} -g ${username} ssh-keygen -q -N '' -t rsa -f /home/${username}/.ssh/id_rsa",
    creates => "/home/${username}/.ssh/id_rsa",
  }
  ->
  file {"/home/${username}/.ssh/authorized_keys":
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0600',
  }
  ->
  exec {"${username}-add-authkey":
    command => "/bin/cat /home/${username}/.ssh/id_rsa.pub >> /home/${username}/.ssh/authorized_keys",
    unless => "/bin/grep \"`/bin/cat /home/${username}/.ssh/id_rsa.pub`\" /home/${username}/.ssh/authorized_keys",
    user => $username,
    group => $username,
  }
}

define bayncore_setup() {

  exec { "remount":
    command => "/bin/mount -a",
    refreshonly => true,
  }

  package {["gfortran"]:
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
    notify => Exec["remount"],
  }

  bayncore_ssh_user {'rogerphilp':
    real_name => "Roger Philp (Bayncore)",
    uid       => 20000
  }

  bayncore_ssh_user {'manelfernandez':
    real_name => "Manel Fernandez (Bayncore)",
    uid       => 20001,
  }

  bayncore_ssh_user {'richardpaul':
    real_name => "Richard Paul (Bayncore)",
    uid       => 20002
  }

}

node /saluki(\d+)?/ {
  include 'dtg::minimal'

  include 'nfs::server'

  $packages = ['build-essential','linux-headers-generic','alien','libstdc++6:i386','vnc4server','bridge-utils']

  package{$packages:
    ensure => installed,
  }
  
  firewall { '050 accept all 10.0.0.0/16':
    action => 'accept',
    source => '10.0.0.0/16'
  }

  firewall { '051 nat 10.0.0.0/16':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => 'all',
    outiface => "em1",
    source   => '10.0.0.0/16',
    table    => 'nat',
  }

  exec { "ipforward":
    command => "/bin/echo 1 > /proc/sys/net/ipv4/ip_forward",
    unless => "/bin/grep 1 /proc/sys/net/ipv4/ip_forward",
  }

  augeas { "sysctl-ipforward":
    context => "/files/etc/sysctl.conf",
    changes => [
                "set net.ipv4.ip_forward 1"
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
