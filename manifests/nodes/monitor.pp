node 'monitor.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'dtg::apache::raven': server_description => 'Monitor'}
  apache::module {'headers':}
  $nagios_ssl = true
  class {'dtg::nagiosserver':}
  class {'munin::gatherer':
    server_name         => $::munin_server,
    extra_apache_config => '    AuthName "Munin access"
    AuthType Ucam-WebAuth
    require valid-user',
  }
  munin::node::plugin {'nagiosstatus':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/nagios/nagiosstatus',
  }
  class {'dtg::firewall::privatehttp':}
  class {'dtg::firewall::publichttps':}
}
if ($::monitor) {
  nagios::monitor {'monitor':
    parents    => 'nas04',
    address    => 'monitor.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor {'nagios':
    parents                     => 'monitor',
    address                     => $::nagios_server,
    hostgroups                  => [ 'http-servers', 'https-servers' ],
    include_standard_hostgroups => false,#don't want to redundantly check df
  }
  nagios::monitor {'munin':
    parents                     => 'monitor',
    address                     => $::munin_server,
    hostgroups                  => [ 'http-servers', 'https-servers' ],
    include_standard_hostgroups => false,
  }
}

