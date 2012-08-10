node "monitor.dtg.cl.cam.ac.uk" {
  include minimal
  class {'nagios_server':}
  nagios_monitor {'monitor':
    parents  => '',
    address => "monitor.dtg.cl.cam.ac.uk",
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
