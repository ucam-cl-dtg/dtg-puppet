node 'cccc-vh315-darkmarkets.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'dtg::apache::raven': server_description => 'CCCC vh315 Dark markets server'}

  class {'apache::ubuntu': } ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':} ->
  apache::module {'ssl':} ->
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
  }
  letsencrypt::certonly { $::fqdn:
    plugin        => 'webroot',
    webroot_paths => ['/var/www/'],
    manage_cron   => true,
    require       => Class['letsencrypt']
  }

  class {'dtg::firewall::publichttp':}

  class {'dtg::firewall::publichttps':}

  file { '/local/data/darkmarkets/':
      ensure => directory,
      mode   => 'u+rwx,go+rx',
      owner  => 'drt24',
      group  => 'drt24',
  }

  file {'/var/www/darkmarkets':
      ensure => link,
      target => '/local/data/darkmarkets/',
  }

}

