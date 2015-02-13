node 'cdn.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  # this script uses the guide here for installing varnish with apache (guide includes http and https)
  # http://blog.ajnicholls.com/varnish-apache-and-https/

  # port configuration
  $apache_http_port = '8080'
  $varnish_http_port = '80'
  $packages = ['varnish']

  # Nasty hack to stop apache listening on port 80.
  $apache_port = $apache_http_port

  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':} ->
  apache::site {'cdn-apache':
    source => 'puppet:///modules/dtg/apache/cdn.conf',
  }  
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

  file { '/var/www/vendor':
    ensure => 'directory',
    owner  => "root",
    group  => "root",
    mode   => '0644',
  }

  file_line{'varnish-setup-backend':
    line   => ".port = \"${apache_http_port}\";",
    notify => Service["varnish"],
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

if ( $::monitor ) {
  nagios::monitor { 'cdn':
    parents    => 'nas04',
    address    => 'cdn.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'cdn': }
}
