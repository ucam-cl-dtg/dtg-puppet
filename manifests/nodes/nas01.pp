node /nas01/ {
  class { 'dtg::minimal': adm_sudoers => false }

  dtg::kernelmodule::add{"bonding": }

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

  class { 'network::interfaces':
    interfaces => {
      'eth0' => {
        'method'      => 'manual',
        'bond-master' => 'bond0',
      },
      'eth1' => {
        'method'      => 'manual',
        'bond-master' => 'bond0',
      },
      'bond0' => {
        'method'          => 'static',
        'address'         => '128.232.20.12',
        'netmask'         => '255.255.252.0',
        'network'         => '128.232.20.0',
        'broadcast'       => '128.232.23.255',
        'gateway'         => '128.232.20.1',
        'dns-nameservers' => $::dns_name_servers,
        'dns-search'      => 'dtg.cl.cam.ac.uk',
        'bond-mode'       => '4',
        'bond-miimon'     => '100',
        'bond-lacp-rate'  => '1',
        'bond-slaves'     => 'eth0 eth1'
      }
    },
    auto       => ['eth0', 'eth1', 'bond0'],
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

  dtg::firewall::nfs {'nfs access from dtg':
    source          => $::local_subnet,
    source_name     => 'dtg',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }

  dtg::firewall::nfs {'nfs access from deviceanalyzer':
    source          => $::deviceanalyzer_ip,
    source_name     => 'deviceanalyzer',
    portmapper_port => $portmapper_port,
    nfs_port        => $nfs_port,
    lockd_tcpport   => $lockd_tcpport,
    lockd_udpport   => $lockd_udpport,
    mountd_port     => $mountd_port,
    rquotad_port    => $rquotad_port,
    statd_port      => $statd_port,
  }

  nfs::export{"/data":
    export => {
      # host           options
      "${::dtg_subnet}" => 'rw,sync,root_squash',
      "${::grapevine_ip}" => 'rw,sync,root_squash',
      "${::shin_ip}" => 'rw,sync,root_squash',
      "${::earlybird_ip}" => 'rw,sync,root_squash',
      "${::deviceanalyzer_ip}" => 'rw,sync,root_squash',
    },
  }
  ->
  nfs::export{"/data/weather":
    export => {
      # host           options
      "${::weather_ip}" => 'rw,sync,root_squash',
      '128.232.28.41' => 'ro,sync,root_squash',#Tien Han Chua's VM
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

  file {'/data/deviceanalyzer':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => 'ug=rwx,o=rx',
  }

  file {'/data/deviceanalyzer-datadivider':
    ensure => directory,
    owner  => 'www-data', 
    group  => 'www-data',
    mode   => 'ug=rwx,o=rx',
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
