node "monitor.dtg.cl.cam.ac.uk" {
  include minimal
  class {'nagios_server':}
  class {'munin::gatherer':
    server_name => 'monitor'
  }
  nagios_monitor {'monitor':
    parents  => '',
    address => "monitor.dtg.cl.cam.ac.uk",
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
