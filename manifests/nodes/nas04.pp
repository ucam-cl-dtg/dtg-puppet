node "nas04.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  include 'nfs::server'
  
  class {'dtg::zfs': }
  
  class {'zfs_auto_snapshot':
    pool_names => [ 'dtg-pool' ]
  }

  cron { 'zfs_weekly_scrub':
    command => "zpool scrub dtg-pool0",
    user => 'root',
    minute => 0,
    minute => 0,
    hour => 0,
    weekday => 1,
  }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'nas04':
    parents    => '',
    address    => 'nas04.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'nas04': }
}
