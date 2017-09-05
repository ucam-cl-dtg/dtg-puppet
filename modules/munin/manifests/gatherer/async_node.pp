define munin::gatherer::async_node ( $override_lines = '', $full_hostname = undef) {
  $munin_node_host = $title
  if ($full_hostname) {
    $munin_node_full_hostname = $full_hostname
  } else {
    $munin_node_full_hostname = "${munin_node_host}.${::org_domain}"
  }
  file { "/etc/munin/munin-conf.d/${munin_node_host}":
    ensure  => present,
    content => template('munin/node-async.erb'),
    require => File['/etc/munin/munin-conf.d/'],
  }
}
