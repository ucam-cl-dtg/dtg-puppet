if ( $::monitor ) {
  nagios::monitor { 'shalmaneser3':
    parents    => '',
    address    => 'shalmaneser3.sec.cl.cam.ac.uk',
    hostgroups => ['ssh-servers'],
  }
  nagios::monitor { 'shalmaneser4':
    parents    => '',
    address    => 'shalmaneser4.sec.cl.cam.ac.uk',
    hostgroups => ['ssh-servers'],
  }
}

