#Configuration for deviceanalyzer related stuff

node 'deviceanalyzer.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
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
  nagios::monitor { 'deviceanalyzer.dtg':
    parents    => '',
    address    => 'deviceanalyzer.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  munin::gatherer::configure_node { 'hound3': }
  munin::gatherer::configure_node { 'hound4': }
  munin::gatherer::configure_node { 'deviceanalyzer': }
}