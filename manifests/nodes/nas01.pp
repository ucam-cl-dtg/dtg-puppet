node /nas01/ {
  class { 'dtg::minimal': adm_sudoers => false }

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

  $portmapper_port     = 111
  $nfs_port            = 2049
  $lockd_tcpport       = 32803
  $lockd_udpport       = 32769
  $mountd_port         = 892
  $rquotad_port        = 875
  $statd_port          = 662
  $statd_outgoing_port = 2020
  
  # We have to tell the NFS server to use a particular set of ports
  # and then open the relevant firewall holes
  include 'nfs::server'
  augeas { "nfs-kernel-server":
    context => "/files/etc/default/nfs-kernel-server",
    changes => [
                "set LOCKD_TCPPORT $lockd_tcpport",
                "set LOCKD_UDPPORT $lockd_udpport",
                "set MOUNTD_PORT $mountd_port",
                "set RQUOTAD_PORT $rquotad_port",
                "set STATD_PORT $statd_port",
                "set STATD_OUTGOING_PORT $statd_outgoing_port",
                ],
    notify => Service['nfs-kernel-server']
  }
  ->
  firewall { "030-nfs accept tcp $portmapper_port (sunrpc) from dtg":
    proto   => 'tcp',
    dport   => $portmapper_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "031-nfs accept udp $portmapper_port (sunrpc) from dtg":
    proto   => 'udp',
    dport   => $portmapper_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "032-nfs accept tcp $nfs_port (nfs) from dtg":
    proto   => 'tcp',
    dport   => $nfs_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "033-nfs accept tcp $lockd_tcpport (lockd) from dtg":
    proto   => 'tcp',
    dport   => $lockd_tcpport,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "034-nfs accept udp $lockd_udpport (lockd) from dtg":
    proto   => 'udp',
    dport   => $lockd_udpport,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "035-nfs accept tcp $mountd_port (mountd) from dtg":
    proto   => 'tcp',
    dport   => $mountd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "036-nfs accept udp $mountd_port (mountd) from dtg":
    proto   => 'udp',
    dport   => $mountd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "037-nfs accept tcp $rquotad_port (rquotad) from dtg":
    proto   => 'tcp',
    dport   => $rquotad_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "038-nfs accept udp $rquotad_port (rquotad) from dtg":
    proto   => 'udp',
    dport   => $rquotad_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "039-nfs accept tcp $statd_port (statd) from dtg":
    proto   => 'tcp',
    dport   => $statd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  firewall { "039-nfs accept udp $statd_port (statd) from dtg":
    proto   => 'udp',
    dport   => $statd_port,
    source  => $::local_subnet,
    action  => 'accept',
  }
  ->
  nfs::export{"/data":
    export => {
      # host           options
      "${::dtg_subnet}" => 'rw,sync,root_squash',
      "${::grapevine_ip}" => 'rw,sync,root_squash',
      "${::shin_ip}" => 'rw,sync,root_squash',
      "${::earlybird_ip}" => 'rw,sync,root_squash',
      "${::weather_ip}" => 'rw,sync,root_squash',
      # TODO restrict weather to just /data/weather or similar
    },
  }

  # The smartd class uses DEFAULT directive in smartd.conf which doesn't seem to be
  # supported by the current stable version in ubuntu.  Therefore as a workaround
  # I've set the options on devicescan.  Once the version in ubuntu catches up we can
  # remove devicescan_options here
  class { "smartd": 
    mail_to            => "dtg-infra@cl.cam.ac.uk",
    service_name       => 'smartmontools',
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
    source => 'puppet:///modules/dtg/motd/nas01-disk-info'
  }

  # Backups
  # We take backups of various servers onto nas01 these are run as low priority cron jobs
  # and run as very restricted user.
  class { "dtg::backup::host":
    directory => '/data/backups',
  }
  dtg::backup::hostsetup{'git_repositories':
    user => 'git',
    host => 'code.dtg.cl.cam.ac.uk',
    require => Class["dtg::backup::host"],
  }
  dtg::backup::hostsetup{'nexus_repositories':
    user => 'nexus',
    host => 'code.dtg.cl.cam.ac.uk',
    require => Class["dtg::backup::host"],
  }

  user {'weather':
    ensure => 'present',
    uid => 501,
    gid => 'www-data',
  }

  file {'/data/weather':
    ensure => directory,
    owner => 'weather',
    group => 'www-data',
    mode => 'ug=rwx,o=rx',
  }

  augeas { "default_grub":
    context => "/files/etc/default/grub",
    changes => [
                "set GRUB_RECORDFAIL_TIMEOUT 2",
                "set GRUB_HIDDEN_TIMEOUT 0",
                "set GRUB_TIMEOUT 2"
                ],
  }


}

if ( $::monitor ) {
  nagios::monitor { 'nas01':
    parents    => '',
    address    => 'nas01.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'nas01': }
}
