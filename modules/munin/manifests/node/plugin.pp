define munin::node::plugin( $ensure = 'symlink', $target = '') {
  $base = '/usr/share/munin/plugins'
  if ( $target ) {
    if ( $target =~ /\/.*/ ) {
      $target_path = $target
    } else {
      $target_path = "${base}/${target}"
    }
  } else {
    $target_path = "${base}/${title}"
  }
  $link = "/etc/munin/plugins/${title}"

  file { $link:
    ensure  => $ensure,
    target  => $target_path,
    require => Package['munin-node'],
    notify  => Service['munin-node'],

  }
}
