class nagios::server inherits nagios::params {
  $nagios_base_dir = $nagios::params::base_dir
  $nagios_plugins_base_dir = $nagios::params::plugins_base_dir

  package { [ 'nagios3', 'libxml-rss-perl' ]:
    ensure => present,
  }
  File { owner => 'root', group => 'root',}

  file { "${nagios_base_dir}/conf.d/contacts_nagios2.cfg":
    ensure  => present,
    content => template('nagios/nagios3/conf.d/contacts_nagios2.cfg.erb'),
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  file { "${nagios_base_dir}/conf.d/generic-host_nagios2.cfg":
    ensure  => present,
    source  => 'puppet:///modules/nagios/nagios3/conf.d/generic-host_nagios2.cfg',
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  concat { "${nagios_base_dir}/conf.d/services_nagios2.cfg":
    ensure  => present,
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  file { "${nagios_base_dir}/commands.cfg":
    ensure  => present,
    content => template('nagios/nagios3/commands.cfg.erb'),
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  concat { "${nagios_base_dir}/conf.d/hostgroups_nagios2.cfg":
    ensure  => present,
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  file { "${nagios_base_dir}/cgi.cfg":
    ensure  => present,
    source  => 'puppet:///modules/nagios/nagios3/cgi.cfg',
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  file { "${nagios_base_dir}/apache2.conf":
    ensure  => present,
    source  => 'puppet:///modules/nagios/nagios3/apache2.conf',
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }

  # Include plugin config directory 
  file { "${nagios_plugins_base_dir}/":
    ensure  => directory,
    source  => 'puppet:///modules/nagios/nagios-plugins/config',
    recurse => true,
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }
  file { "${nagios_plugins_base_dir}/epager.cfg":
    ensure  => file,
    content => template('nagios/nagios-plugins/config/epager.cfg.erb'),
    notify  => Service['nagios3'],
    require => Package['nagios3']
  }

  # Include custom nagios commands
  file { '/usr/local/share/nagios':
    ensure  => directory,
    recurse => true,
  }

  file { '/usr/local/share/nagios/plugins':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/nagios/nagios-plugins/plugins',
    require => [ File['/usr/local/share/nagios'],  Package['nagios3'] ]
  }
  file { '/usr/local/share/nagios/plugins/all.xml':
    ensure  => file,
    content => template('nagios/nagios-plugins/plugins/all.xml.erb'),
    require => [ File['/usr/local/share/nagios'],  Package['nagios3'] ]
  }


  # this is the directory in which we publish our rss feed
  file { '/var/www/nagios':
    ensure => directory,
    owner  => 'nagios',
    mode   => '0755'
  }
  file { '/var/www/nagios/all.xml':
    ensure  => present,
    owner   => 'nagios',
    mode    => '0644',
    replace => no,
    content => template('nagios/nagios-plugins/plugins/all.xml.erb'),
  }

  # the extinfo_nagios2.cfg file defines a debian-servers host group
  # which is useless to us but will generate nagios errors because none
  # of our servers refer to it
  file { "${nagios_base_dir}/conf.d/extinfo_nagios2.cfg":
    ensure => absent
  }

  file { "${nagios_base_dir}/conf.d/nodes":
    ensure  => directory,
    recurse => true, # so that nodes get deleted if deconfigured
    purge   => true,
    require => Package['nagios3'],
  }

  file { "${nagios_base_dir}/conf.d/contacts":
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package['nagios3'],
  }
  file { "${nagios_base_dir}/conf.d/contactgroups":
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package['nagios3'],
  }
  file { "${nagios_base_dir}/conf.d/services":
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package['nagios3'],
  }
  service { 'nagios3':
    ensure  => running,
    enable  => true,
    require => Package['nagios3'],
  }

  # ensure user that will collect scp'ed logs from our nagios
  # hosts exists
  user { 'nagios-collector':
    ensure     => 'present',
    comment    => 'nagios collector',
    home       => '/home/nagios-collector',
    managehome => true,
    password   => '*',
  }

  file { '/home/nagios-collector/server-status-reports':
    ensure  => directory,
    owner   => 'nagios-collector',
    group   => 'nagios-collector',
    require => User['nagios-collector'],
  }

  file { '/home/nagios-collector/.monkeysphere/':
    ensure  => directory,
    owner   => 'nagios-collector',
    group   => 'nagios-collector',
    require => User['nagios-collector'],
  }

  file { '/home/nagios-collector/.monkeysphere/authorized_user_ids':
    ensure => file,
    owner  => 'nagios-collector',
    group  => 'nagios-collector',
  }

  # Setup apache
  class { 'apache': }
  apache::site { 'nagios':
    content => template('nagios/apache/nagios.conf.erb')
  }
  if $::nagios_ssl {
    letsencrypt::certonly { $::nagios_server:
      plugin        => 'webroot',
      webroot_paths => ['/usr/share/nagios3/htdocs/'],
      manage_cron   => true,
      require       => Class['letsencrypt'],
    }

    apache::module { 'ssl': }
    apache::port { 'ssl': port => 443 }
  }
  # remove the nagios file that provides access via /nagios3
  file { '/etc/apache2/conf.d/nagios3.conf':
    ensure => absent
  }
}
