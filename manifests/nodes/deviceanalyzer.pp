#Configuration for deviceanalyzer related stuff

node 'deviceanalyzer.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  # open up ports 80,443,2468
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  firewall { "030-xmlsocketserver accept tcp 2468 (xmlsocketserver) from anywhere":
    proto   => 'tcp',
    dport   => 2468,
    action  => 'accept',
  }

  # Packages which should be installed
  $packagelist = ['jetty8', 'nginx']
  package {
    $packagelist:
      ensure => installed
  }
}
if ( $::monitor ) {
  nagios::monitor { 'hound3':
    parents    => '',
    address    => 'hound3.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'hound4':
    parents    => '',
    address    => 'hound4.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'deviceanalyzer':
    parents    => 'hound3',
    address    => 'deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
  nagios::monitor { 'secure.deviceanalyzer':
    parents    => 'hound3',
    address    => 'secure.deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
  nagios::monitor { 'upload.deviceanalyzer':
    parents    => 'hound3',
    address    => 'upload.deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
  nagios::monitor { 'deviceanalyzer.dtg':
    parents    => '',
    address    => 'deviceanalyzer.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  munin::gatherer::configure_node { 'hound3': }
  munin::gatherer::configure_node { 'hound4': }
  munin::gatherer::configure_node { 'deviceanalyzer': }
}