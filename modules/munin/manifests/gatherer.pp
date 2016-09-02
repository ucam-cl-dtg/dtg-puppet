class munin::gatherer(
  $listen_ip = '*',
  $server_name = 'munin',
  $tls_cert_file = undef,
  $tls_cert_chain_file = undef,
  $tls_key_file = undef,
  $graph_strategy = 'cgi',
  $html_strategy = 'cgi',
  $alerts_email = $from_address,
  $contact = 'dtg',
  $graph_data_size = 'huge',
  $extra_apache_config = '',
  $lets_encrypt = true,
) {
  package { [ 'munin', 'libcgi-fast-perl', 'libapache2-mod-fcgid' ]:
    ensure => installed
  }
  exec {'Enable mod rewrite':
    command   => 'a2enmod rewrite'
  }
  file { '/etc/munin/munin-conf.d/':
    ensure  => directory,
    require => Package['munin'],
  }

  apache::site { 'munin':
    content => template('munin/munin.erb')
  }
  file { '/etc/apache2/conf.d/munin':
    ensure => absent,
  }
  file { '/etc/munin/munin.conf':
    content => template('munin/munin-conf.erb'),
  }
  if $lets_encrypt {
    letsencrypt::certonly { $server_name:
      plugin        => 'webroot',
      webroot_paths => ['/var/cache/munin/www/'],
      manage_cron   => true,
      require       => Class['letsencrypt'],
    }
  }
}
