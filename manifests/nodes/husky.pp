if ( $::monitor ) {
  munin::gatherer::configure_node { 'husky0': }
  munin::gatherer::configure_node { 'husky1': }
  munin::gatherer::configure_node { 'husky2': }
  munin::gatherer::configure_node { 'husky3': }
  munin::gatherer::configure_node { 'husky4': }
}
