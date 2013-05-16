node /nas01/ {
  include 'dtg::minimal'

  # Its important to probe these modules in this particular order because it affects which device id they get, which in turn affects the fancontrol config
  dtg::kernelmodule::add{"coretemp": }
  ->
  # Control the fan speeds.  This requires a particular kernel module to be manually loaded
  dtg::kernelmodule::add{"w83627ehf": }
  ->
  package{'lm-sensors':
    ensure => installed
  }
  ->
  package{'fancontrol':
    ensure => installed
  }
  ->
  file{"/etc/fancontrol":
    source => 'puppet:///modules/dtg/fancontrol/nas01'
  }

  # We have to tell the NFS server to use a particular set of ports
  # and then open the relevant firewall holes
  include 'nfs::server'
  file{"/etc/default/nfs-kernel-server":
    source => 'puppet:///modules/dtg/nfs/nas-nfs-kernel-server',
    notify => Service['nfs-kernel-server']
  }
  ->
  firewall { '030-nfs accept tcp 111 (sunrpc) from dtg':
    proto   => 'tcp',
    dport   => '111',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '031-nfs accept udp 111 (sunrpc) from dtg':
    proto   => 'udp',
    dport   => '111',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '032-nfs accept tcp 2049 (nfs) from dtg':
    proto   => 'tcp',
    dport   => '2049',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '033-nfs accept tcp 32803 (lockd) from dtg':
    proto   => 'tcp',
    dport   => '32803',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '034-nfs accept udp 32769 (lockd) from dtg':
    proto   => 'udp',
    dport   => '32769',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '035-nfs accept tcp 892 (mountd) from dtg':
    proto   => 'tcp',
    dport   => '892',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '036-nfs accept udp 892 (mountd) from dtg':
    proto   => 'udp',
    dport   => '892',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '037-nfs accept tcp 875 (rquotad) from dtg':
    proto   => 'tcp',
    dport   => '875',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '038-nfs accept udp 875 (rquotad) from dtg':
    proto   => 'udp',
    dport   => '875',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '039-nfs accept tcp 662 (statd) from dtg':
    proto   => 'tcp',
    dport   => '662',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { '039-nfs accept udp 662 (statd) from dtg':
    proto   => 'udp',
    dport   => '662',
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  nfs::export{"/data":
    export => {
      # host           options
      "${::local_subnet}" => 'rw,sync,root_squash,no_subtree_check'
    },
  }

  # The smartd class uses DEFAULT directive in smartd.conf which doesn't seem to be
  # supported by the current stable version in ubuntu.  Therefore as a workaround
  # I've set the options on devicescan.  Once the version in ubuntu catches up we can
  # remove devicescan_options here
  class { "smartd": 
    mail_to => "dtg-infra@cl.cam.ac.uk",
    devicescan_options => "-m dtg-infra@cl.cam.ac.uk -M daily"
  }
  ->
  munin::node::plugin{'smart_sda':
    target => "smart_"
  }
  ->
  munin::node::plugin{'smart_sdb':
    target => "smart_"
  }
  ->
  munin::node::plugin{'smart_sdc':
    target => "smart_"
  }
  ->
  munin::node::plugin{'smart_sdd':
    target => "smart_"
  }
  ->
  munin::node::plugin{'smart_sde':
    target => "smart_"
  }
  ->
  munin::node::plugin{'smart_sdf':
    target => "smart_"
  }
  ->
  munin::node::plugin{'smart_sdg':
    target => "smart_"
  }

  file {"/etc/update-motd.d/10-help-text":
    ensure => absent
  }

  file {"/etc/update-motd.d/50-landscape-sysinfo":
    ensure => absent
  }

  file{"/etc/update-motd.d/20-disk-info":
    source => 'puppet:///modules/dtg/motd/nas-disk-info'
  }

}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'nas01':
    parents    => '',
    address    => 'nas01.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'nas01': }
}
