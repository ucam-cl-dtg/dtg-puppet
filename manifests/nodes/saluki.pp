node /saluki(\d+)?/ {
  include 'dtg::minimal'

  $packages = ['build-essential','linux-headers-generic','alien','nfs-kernel-server','libstdc++6:i386']

  firewall { '050 accept all 172.31.0.0/16':
    action => 'accept',
    source => '172.31.0.0/16'
  }
  
  package{$packages:
    ensure => installed,
  }
  ->
  file {'/bayncore':
    ensure => directory,
  }
  ->
  file_line { 'mount nas04':
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/bayncore /bayncore nfs defaults 0 0',
    path   => '/etc/fstab',
    ensure => present,
  }
  ->
  nfs::export{["/home","/bayncore"]:
    export => {
      "172.31.0.0/16" => "rw,no_subtree_check,insecure,no_root_squash",
    },
  }
  
}


if ( $::monitor ) {
  nagios::monitor { 'saluki1':
    parents    => 'se18-r8-sw1',
    address    => 'saluki1.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'saluki1': }

  nagios::monitor { 'saluki2':
    parents    => 'se18-r8-sw1',
    address    => 'saluki2.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'saluki2': }
}
