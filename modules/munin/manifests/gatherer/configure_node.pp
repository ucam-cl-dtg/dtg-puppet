define munin::gatherer::configure_node ( $override_lines = '') {
  $munin_node_host = $title
  file { "/etc/munin/munin-conf.d/${munin_node_host}":
    ensure  => present,
    content => template('munin/node.erb'),
    require => File['/etc/munin/munin-conf.d/'],
  }
}
