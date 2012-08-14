node "monitor.dtg.cl.cam.ac.uk" {
  include monitor
  class {'nagios_server':}
  class {'munin::gatherer':
    server_name => $::munin_server
  }
  nagios_monitor {'monitor':
    parents    => '',
    address    => "monitor.dtg.cl.cam.ac.uk",
    hostgroups => [ 'ssh-servers' ],
  }
  nagios_monitor {'nagios':
    parents => 'monitor',
    address => $::nagios_server,
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,#don't want to redundantly check df
  }
  nagios_monitor {'munin':
    parents => 'monitor',
    address => $::munin_server,
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
}
