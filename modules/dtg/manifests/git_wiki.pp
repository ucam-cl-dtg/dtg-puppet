class dtg::git_wiki {
  file {'/home/lc525/lc525.pub':
    ensure => file,
    owner  => 'lc525',
    group  => 'lc525',
    mode   => '0644',
    source => 'puppet:///modules/dtg/ssh/lc525.pub',
  }
  class {'dtg::git::gitolite':
    admin_key => '/home/lc525/lc525.pub',
    require   => File['/home/lc525/lc525.pub'],
  }
}
# admin_key is the key to use for the first gitolite admin
class dtg::git::gitolite ($admin_key){
  # Setup gitolite package
  $gitolite_wikipackages = ['gitolite']
  package {$gitolite_wikipackages :
    ensure => installed,
  }
  group {'git': ensure => present,}
  user {'git':
    ensure  => present,
    home    => '/srv/git/',
    gid     => 'git',
    comment => 'Git Version Control',
    shell   => '/bin/bash',
    password => '*',#no password but key based login
  }
  file {'/local/data/git':
    ensure => directory,
    owner  => 'git',
    group  => 'git',
    mode   => '2755',
  }
  file {'/srv/git/':
    ensure => link,
    target => '/local/data/git/',
  }
  #TODO(drt24) setup backups and restore from backups
  file {'/usr/share/gitolite/conf/wiki.gitolite.rc':
    ensure => file,
    source => 'puppet:///modules/dtg/wiki.gitolite.rc',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['gitolite'],
  }
  exec {'setup-gitolite':
    command => "sudo -H -u git -g git gl-setup ${admin_key}",
    cwd     => '/srv/git/',
    creates => '/srv/git/repositories/',
    require => File[$admin_key, '/usr/share/gitolite/conf/wiki.gitolite.rc'],
  }
  file {'/srv/git/.ssh/':
    ensure => directory,
    owner  => 'git',
    group  => 'git',
    mode   => '0700',
  }
  file {'/srv/git/.ssh/authorized_keys':
    ensure => file,
    owner  => 'git',
    group  => 'git',
    mode   => '0600',
  }
  dtg::backup::serversetup {'gitolite repositories':
    backup_directory   => '/srv/git/repositories/',
    script_destination => '/srv/git/backup',
    user               => 'git',
    home               => '/srv/git/',
    require            => Exec['setup-gitolite'],
  }
}
# Some things need to be done before gollum is installed (ruby)
class dtg::git::gollum::pre {
  # Setup gitlab
  $gollumpackages = ['ruby1.9.1', 'ruby1.9.1-dev', 'ruby-bundler', 'python-pygments', 'libicu-dev', 'libxslt1-dev','libxml2-dev', 'libcurl4-openssl-dev', 'libreadline6-dev', 'libssl-dev', 'redis-server', 'python-dev', 'libyaml-dev', 'make', 'build-essential']
  package {$gitlabpackages :
    ensure => installed,
  }
  # Use ruby 1.9.1 to provide ruby
  dtg::alternatives{'ruby':
    linkto => '/usr/bin/ruby1.9.1',
    require => Package['ruby1.9.1','ruby1.9.1-dev'],
  }
  
  package {'passenger':
    ensure => 'latest',
    provider => 'gem',
    require => Dtg::Alternatives['ruby'],
  }
  
  exec { 'install apache passenger module':
    command => 'sudo passenger-install-apache2-module',
    creates => '/srv/gollum/vendor/bundle/',
    cwd     => '/srv/gollum/',
    require => Package['passenger','apache'],
  }
}

# Stuff that needs to be done for installing gollum
class dtg::git::gollum::main {
  vcsrepo {'/srv/gollum/':
    ensure   => latest,
    provider => 'git',
    source   => 'git://github.com/lc525/gollum-dtg.git',
    revision => 'dtg-master',
    owner    => 'lc525',
    group    => 'lc525',
    require  => File['/srv/gollum/'],
  }
  exec {'install gollum bundle':
    command => 'sudo -u lc525 -g lc525 -H bundle install --without development test --deployment',
    creates => '/srv/gollum/vendor/bundle/',
    cwd     => '/srv/gollum/',
    require => [Dtg::Alternatives['ruby']],
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
  apache::site{'gollum':
    source => 'puppet:///modules/dtg/gollum/apache.conf'
  }
}

