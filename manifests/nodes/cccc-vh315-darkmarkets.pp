node 'cccc-vh315-darkmarkets.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'dtg::apache::raven': server_description => 'CCCC vh315 Dark markets server'}

  class {'apache::ubuntu': } ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':} ->
  apache::site {'cccc-vh315-darkmarkets':
    source => 'puppet:///modules/dtg/apache/cccc-vh315-darkmarkets.conf',
  }

  file { '/etc/apache2/conf-available/cachingserver-rules.conf':
      mode   => 'u+rw,go+r',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/dtg/apache/cachingserver-rules.conf',
      notify => Service['apache2']
  }


  # Use letsencrypt to get a certificate
  class {'letsencrypt':
    email          => $::from_address,
    configure_epel => false,
    require        => [Service['apache2'], Class['dtg::firewall::publichttp']],
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
  }

  class {'dtg::firewall::publichttp':}

  class {'dtg::firewall::publichttps':}
}

