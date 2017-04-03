# Stuff that needs to be done for installing gollum
class dtg::git::gollum::main {
  vcsrepo {'/srv/gollum/':
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/ucam-cl-dtg/gollum-dtg.git',
    revision => 'dtg-multiwiki',
    owner    => 'www-data',
    group    => 'www-data',
  }
  exec {'install gollum bundle':
    # command => '/usr/local/rvm/bin/rvm 1.9.3-p194@gollum do bundle install',
    command => '/usr/local/rvm/bin/rvm all do bundle install --without development test --deployment',
    creates => '/srv/gollum/vendor/bundle/',
    cwd     => '/srv/gollum/',
    logoutput => true,
    require => [ Rvm_system_ruby['ruby-1.9.3-p194'], Vcsrepo['/srv/gollum/'] ];
  }
  exec {'gollum frontend permissions':
    command => 'chgrp -R www-data .; chown -R www-data .',
    cwd     => '/srv/gollum/lib/gollum/frontend',
    require => Vcsrepo['/srv/gollum/'],
  }
  file {'/srv/gollum/lib/gollum/frontend/config.ru':
    ensure  => file,
    source  => 'puppet:///modules/dtg/gollum/config.ru',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0775',
    require => Vcsrepo['/srv/gollum/'],
  }

# Install apache
  class{'apache':} ->
  apache::module {'ssl':} ->
  apache::module{'headers':} ->
  apache::module{'autoindex':
    ensure  => absent
  } ->
# Use letsencrypt to get a certificate
  class {'letsencrypt':
    email          => $::from_address,
    configure_epel => false,
  } ->
  letsencrypt::certonly { $::fqdn:
    plugin        => 'webroot',
    webroot_paths => ['/srv/gollum/lib/gollum/frontend/public/'],
    manage_cron   => true,
  } ->
# Configure the website
  apache::site{'gollum':
    source => 'puppet:///modules/dtg/gollum/apache.conf'
  }


}
