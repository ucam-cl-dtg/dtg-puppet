if ( $::monitor ) {
  nagios::monitor { 'shalmaneser3':
    parents    => '',
    address    => 'shalmaneser3.sec.cl.cam.ac.uk',
    hostgroups => ['ssh-servers'],
  }
  munin::gatherer::configure_node { 'shalmaneser4':
    address => 'shalmaneser4.sec.cl.cam.ac.uk',
  }
  nagios::monitor { 'shalmaneser4':
    parents    => '',
    address    => 'shalmaneser4.sec.cl.cam.ac.uk',
    hostgroups => ['ssh-servers'],
  }
}

