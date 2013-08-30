if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'nas02':
    parents    => '',
    address    => 'nas02.cl.cam.ac.uk',
    hostgroups => [ ],
  }
}
