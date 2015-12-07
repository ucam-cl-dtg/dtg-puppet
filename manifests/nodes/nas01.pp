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

  # bonded nics
  class { 'dtg::bonding': address => '128.232.20.12'}

  include 'dtg::nfs'

  dtg::nfs::firewall {'dtg':
    source          => $::local_subnet,
  }

  dtg::nfs::firewall {'deviceanalyzer':
    source          => $::deviceanalyzer_ip,
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
    parents    => 'se18-r8-sw1',
    address    => 'nas01.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'nfs-servers' ],
  }
  munin::gatherer::configure_node { 'nas01': }
}
