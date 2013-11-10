node "monitor.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  class {'dtg::apache::raven': server_description => 'Monitor'}
  apache::module {'headers':}
  $nagios_ssl = true
  class {'nagios::server':}
  class {'munin::gatherer':
    server_name => $::munin_server
  }
  munin::node::plugin {'nagiosstatus':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/nagios/nagiosstatus',
  }
  class {'dtg::firewall::privatehttp':}
  class {'dtg::firewall::publichttps':}
}
if ($::monitor) {
  nagios::monitor {'monitor':
    parents    => '',
    address    => "monitor.dtg.cl.cam.ac.uk",
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor {'nagios':
    parents => 'monitor',
    address => $::nagios_server,
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,#don't want to redundantly check df
  }
  nagios::monitor {'munin':
    parents => 'monitor',
    address => $::munin_server,
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
}

