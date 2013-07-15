if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'nas04':
    parents    => '',
    address    => 'nas04.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'nas04': }
}
