class munin::gatherer(
  $listen_ip = "*",
  $server_name = "munin",
  $tls_cert_file = undef,
  $tls_cert_chain_file = undef,
  $tls_key_file = undef,
  $graph_strategy = "cgi",
  $html_strategy = "cgi",
  $alerts_email = $from_address,
  $contact = "dtg"
) {
  package { [ "munin", "libcgi-fast-perl", "libapache2-mod-fcgid" ]:
    ensure => installed
  }
  exec {'Enable mod rewrite':
    command   => "a2enmod rewrite"
  }
  file { '/etc/munin/munin-conf.d/':
    ensure => directory,
    require => Package['munin'],
  }

  apache::site { "munin.conf": 
    content => template("munin/munin.erb")
  }
  file { "/etc/apache2/conf.d/munin":
    ensure => absent,
  }
  file { "/etc/munin/munin.conf":
    content => template("munin/munin-conf.erb"),
  }
}

define munin::gatherer::configure_node ( $override_lines = '') {
  $munin_node_host = $title
  file { "/etc/munin/munin-conf.d/$munin_node_host":
    ensure  => present,
    content => template("munin/node.erb"),
    require => File["/etc/munin/munin-conf.d/"],
  }
}

define munin::node::plugin( $ensure = "symlink", $target = "") {
  $base = "/usr/share/munin/plugins"
  if ( $target ) {
    if ( $target =~ /\/.*/ ) {
      $target_path = $target
    } else {
      $target_path = "$base/${target}"
    }
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
  $node_allow_ips = ['^127\.0\.0\.1$']
) {
  package { [ "munin-node", "munin-plugins-extra", "libcache-cache-perl" ]:
    ensure => installed
  }
  service { "munin-node":
    ensure => running
  }
  exec { "munin-node-configure":
    command  => '$(munin-node-configure --shell)',
    provider => shell,
  }

  file { "/etc/munin/munin-node.conf":
    ensure => present,
    content => template("munin/munin-node.conf.erb"),
    require => Package["munin-node"],
    notify => Service[ "munin-node"]
  }
  
}
