define munin::gatherer::configure_node ( $override_lines = '', $address = '') {
  $munin_node_host = $title
  if $address == '' {
    $munin_node_address = "${munin_node_host}.${::org_domain}"
  } else {
    $munin_node_address = $address
  }
  file { "/etc/munin/munin-conf.d/${munin_node_host}":
    ensure  => present,
    content => template('munin/node.erb'),
    require => File['/etc/munin/munin-conf.d/'],
  }
}
