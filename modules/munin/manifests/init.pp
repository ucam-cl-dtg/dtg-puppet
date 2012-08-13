class munin::gatherer(
  $listen_ip = "*",
  $server_name = "munin",
  $tls_cert_file = undef,
  $tls_cert_chain_file = undef,
  $tls_key_file = undef 
) {
  package { "munin":
    ensure => installed
  }

  apache::site { "munin.conf": 
    content => template("munin/munin.erb")
  }
  file { "/etc/apache2/conf.d/munin":
    ensure => absent,
  }
}

define munin::gatherer::configure_node () {
  $munin_node_host = $title
  file { "/etc/munin/munin-conf.d/$munin_node_host":
    ensure => present,
    content => template("munin/node.erb")
  }
}

define munin::node::plugin( $ensure = "symlink", $target = "") {
  $base = "/usr/share/munin/plugins"
  if ( $target ) {
    $target_path = "$base/${target}"
  } else {
    $target_path = "$base/${title}"
  }
  $link = "/etc/munin/plugins/${title}"

  file { "$link":
    ensure => $ensure,
    target => $target_path,
    require => Package["munin-node"],
    notify => Service["munin-node"],

  }
}

class munin::node (
  $node_allow_ip = '^127\.0\.0\.1$'
) {
  package { [ "munin-node", "munin-plugins-extra", "libcache-cache-perl" ]:
    ensure => installed
  }
  service { "munin-node":
    ensure => running
  }

  file { "/etc/munin/munin-node.conf":
    ensure => present,
    content => template("munin/munin-node.conf.erb"),
    require => Package["munin-node"],
    notify => Service[ "munin-node"]
  }
  
}
