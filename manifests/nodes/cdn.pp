node 'cdn.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  $apache_http_port = '8080'
  $varnish_http_port = '80'
  $packages = ['varnish']

  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':} ->
  file_line{'apache-port-configure-http':
    line   => "Listen ${apache_http_port}",
    path   => "/etc/apache2/ports.conf",
    match  => '^Listen 80.*$'
  } 
  ->
  file_line{'apache-port-configure-http-virtual-directory':
    line   => "<VirtualHost *:${apache_http_port}>",
    path   => "/etc/apache2/sites-available/000-default.conf",
    notify => Service["apache2"],
    match  => '<VirtualHost \*:.*>'
  } 
  ->
  exec { 'stop-apache':
    command  => 'service apache2 stop'
  }
  ->
  package{$packages:
    ensure => installed
  }
  ->
  service { "varnish":
      ensure  => "running",
      enable  => "true",
      require => Package["varnish"],
  }

  file_line{'varnish-setup-backend':
    line   => ".port = \"${apache_http_port}\";",
    path   => "/etc/varnish/default.vcl",
    match  => '^\.port.*'
  }
  ->
  file_line{'varnish-setup-http-listening-port':
    notify => Service["varnish"],
    line   => "DAEMON_OPTS=\"-a :${varnish_http_port} \\",
    path   => "/etc/default/varnish",
    match  => "^DAEMON_OPTS=.*"
  }
  ->
  exec { 'start-apache':
    command  => 'service apache2 start',
    refreshonly => true
  }

  class {'dtg::firewall::publichttp':}
}

