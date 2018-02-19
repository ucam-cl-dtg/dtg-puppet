if ( $::monitor ) {
  nagios::monitor { 'husky0':
    address    => 'husky0.dtg.cl.cam.ac.uk',
    hostgroups => ['https-servers'],
    parents    => '',
  }

  munin::gatherer::configure_node { 'husky0': }
  munin::gatherer::configure_node { 'husky1': }
  munin::gatherer::configure_node { 'husky2': }
  munin::gatherer::configure_node { 'husky3': }
  munin::gatherer::configure_node { 'husky4': }
}
