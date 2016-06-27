node 'cccc-scanner.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  # port configuration
  $apache_http_port = '8080'
  $apache_ssl_port = '8443'

  $varnish_http_port = '9080'
  $varnish_ssl_port = '9443'
  
  # pound deals with the SSL encryption and decryption.
  $pound_http_port = '80'
  $pound_ssl_port = '443'

  # Nasty hack to stop apache listening on port 80.
  $apache_port = $apache_http_port

  class {'apache::ubuntu': } ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':} ->
  apache::site {'cccc-scanner':
    source => 'puppet:///modules/dtg/apache/cccc-scanner.conf',
  }

  # Configure apache so that it works with pound and varnish
  file_line{'apache-port-configure-http':
    line  => "Listen ${apache_http_port}",
    path  => '/etc/apache2/ports.conf',
    match => '^Listen 80.*$'
  }
  ->
  file_line{'apache-port-configure-ssl':
    line  => "Listen ${apache_ssl_port}",
    path  => '/etc/apache2/ports.conf',
    match => '^Listen .*443.*$'
  }
  ->
  file { '/etc/apache2/conf-available/cachingserver-rules.conf':
      mode   => 'u+rw,go+r',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/dtg/apache/cachingserver-rules.conf',
      notify => Service['apache2']
  }

  # stop apache so that we can use its old ports for pound
  exec { 'stop-apache':
    command => 'systemctl stop apache2',
    onlyif  => 'lsof -i TCP | grep apache | grep \'*:http\'',
    require => Package['lsof'],
  }
  ->
  package{ 'varnish':
    ensure => installed
  }
  ->
  package{ 'pound':
    ensure => installed
  }
  ->
  file_line{'pound-startup':
    line   => 'startup=1',
    path   => '/etc/default/pound',
    match  => '^startup.*$',
    notify => Service['pound']
  }

  exec{'generate pound dhparams':
    command => 'openssl dhparam -out /etc/pound/dhparams.pem 3072',
    creates => '/etc/pound/dhparams.pem',
  }

  service { 'varnish':
      ensure  => 'running',
      enable  => true,
      require => Package['varnish'],
  }

  service { 'pound':
      ensure  => 'running',
      enable  => true,
      require => Package['pound'],
  }

  file { '/etc/pound/pound.cfg':
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/dtg/cccc/pound.cfg',
      notify  => Service['pound'],
      require => [Exec['generate pound dhparams'], Package['pound']],
  }

  file { '/etc/varnish/cdn.vcl':
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/dtg/cdn/varnish/cdn.vcl',
      require => Package['varnish'],
  }
  file{'/etc/systemd/system/varnish.service.d/':
      ensure => directory,
  }
  file{'/etc/systemd/system/varnish.service.d/varnish.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "[Unit]
Description=Varnish HTTP accelerator
Documentation=https://www.varnish-cache.org/docs/4.1/ man:varnishd

[Service]
Type=simple
LimitNOFILE=131072
LimitMEMLOCK=82000
ExecStart=
ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :${varnish_http_port} -a :${varnish_ssl_port} -T localhost:6082 -f /etc/varnish/cdn.vcl -S /etc/varnish/secret -s malloc,256m
ExecReload=/usr/share/varnish/reload-vcl
ProtectSystem=full
ProtectHome=true
PrivateTmp=true
PrivateDevices=true

[Install]
WantedBy=multi-user.target
",
      notify  => Service['varnish']
  } ->
  file{'/etc/systemd/system/multi-user.target.wants/varnish.service':
    ensure => link,
    target => '/etc/systemd/system/varnish.service.d/varnish.conf',
  } ->
  exec { 'start-apache':
    command => 'systemctl start apache2',
    unless  => 'systemctl is-active apache2.service',
  }

  vcsrepo { '/etc/www-bare':
    ensure   => bare,
    provider => git,
    source   => 'git://github.com/ucam-cl-dtg/cccc-scanner-www',
    owner    => 'root',
    group    => 'root'
  }
  ->
  file { '/etc/www-bare/hooks/post-update':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0775',
    source => 'puppet:///modules/dtg/cccc/post-update-www.hook',
  }
  ->
  exec { 'run-www-hook':
    command => '/etc/www-bare/hooks/post-update',
    creates => '/var/www/.git',
  }
  # Use letsencrypt to get a certificate
  class {'letsencrypt':
    email          => $::from_address,
    configure_epel => false,
    require        => [Service['apache2'], Service['pound'], Service['varnish']],
  } ->
  exec {'letsencrypt first run without working pound':
    command => "letsencrypt --agree-tos certonly -a standalone -d ${::fqdn} && cat /etc/letsencrypt/live/${::fqdn}/privkey.pem /etc/letsencrypt/live/${::fqdn}/fullchain.pem > /etc/letsencrypt/live/${::fqdn}/privkey_fullchain.pem && service pound restart",
    unless  => 'lsof -i TCP | grep pound | grep \'*:http\'',
    require => Package['lsof'],
  }
  letsencrypt::certonly { $::fqdn:
    plugin          => 'webroot',
    webroot_paths   => ['/var/www/'],
    manage_cron     => true,
    # Evil hack because pound requires everything in the same file
    additional_args => [" && cat /etc/letsencrypt/live/${::fqdn}/privkey.pem /etc/letsencrypt/live/${::fqdn}/fullchain.pem > /etc/letsencrypt/live/${::fqdn}/privkey_fullchain.pem"],
    require         => Class['letsencrypt']
  } ->
  exec {'restart pound':
    command     => 'service pound restart',
    refreshonly => true,
  }

  class {'dtg::firewall::publichttp':}

  class {'dtg::firewall::publichttps':}
}

if ( $::monitor ) {
  nagios::monitor { 'cccc-scanner':
    parents    => 'nas04',
    address    => 'cccc-scanner.dtg.cl.cam.ac.uk',
    hostgroups => ['ssh-servers', 'http-servers', 'https-servers'],
  }
  
  munin::gatherer::async_node { 'cccc-scanner': }
}
