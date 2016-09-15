define munin::gatherer::async_node ( $override_lines = '') {
  $munin_node_host = $title
  file { "/etc/munin/munin-conf.d/${munin_node_host}":
    ensure  => present,
    content => template('munin/node-async.erb'),
    require => File['/etc/munin/munin-conf.d/'],
  }
}
