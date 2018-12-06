if ( $::monitor ) {
  munin::gatherer::configure_node { 'shalmaneser3':
    address => 'shalmaneser3.sec.cl.cam.ac.uk',
  }
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
  munin::gatherer::configure_node { 'shalmaneser5':
    address => 'shalmaneser5.sec.cl.cam.ac.uk',
  }
  nagios::monitor { 'shalmaneser5':
    parents    => '',
    address    => 'shalmaneser5.sec.cl.cam.ac.uk',
    hostgroups => ['ssh-servers', 'https-servers'],
  } ->
  nagios::monitor { 'data.cambridgecybercrime.uk':
    parents    => 'shalmaneser5',
    address    => 'data.cambridgecybercrime.uk',
    hostgroups => ['https-servers'],
  }
  munin::gatherer::configure_node { 'shalmaneser6':
    address => 'shalmaneser6.sec.cl.cam.ac.uk',
  }
  nagios::monitor { 'shalmaneser6':
    parents    => '',
    address    => 'shalmaneser6.sec.cl.cam.ac.uk',
    hostgroups => ['ssh-servers'],
  }
}

