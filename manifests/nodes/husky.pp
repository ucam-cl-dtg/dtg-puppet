if ( $::monitor ) {
  nagios::monitor { 'husky0':
    address    => 'husky0.dtg.cl.cam.ac.uk',
    hostgroups => ['https-servers'],
    parents    => 'se18-r8-sw1',
  }

  munin::gatherer::async_node { 'husky0': }
  munin::gatherer::async_node { 'husky1': }
  munin::gatherer::async_node { 'husky2': }
  munin::gatherer::async_node { 'husky3': }
  munin::gatherer::async_node { 'husky4': }
}
