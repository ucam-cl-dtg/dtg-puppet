#Configuration for deviceanalyzer related stuff

if ( $::monitor ) {
  nagios::monitor { 'hound3':
    parents    => '',
    address    => 'hound3.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'hound4':
    parents    => '',
    address    => 'hound4.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'deviceanalyzer':
    parents    => 'hound3',
    address    => 'deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
  munin::gatherer::configure_node { 'hound3': }
  munin::gatherer::configure_node { 'hound4': }
}

