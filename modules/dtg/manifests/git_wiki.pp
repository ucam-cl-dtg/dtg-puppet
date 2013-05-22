# git_wiki.pp 
# Maintainer: Lucian Carata <lc525@cam.ac.uk>
# 
# This installs dtg-gollum (https://github.com/lc525/gollum-dtg),
# the DTG wiki server and corresponding git-backed wikis
#

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
    repo_group => 'www-data',
    repo_mode  => '0775',
    repo_recurse => true,
    require   => File['/home/lc525/lc525.pub'],
  }

  class {'dtg::git::gollum::pre':}
  class {'dtg::git::gollum::main':}
}

# Install ruby and passenger before gollum
class dtg::git::gollum::pre {
    include rvm
    #rvm::system_user{ lc525: }
    
    rvm_system_ruby{'ruby-1.9.3-p194':
      ensure => present,
      default_use => true;
    }
    
    rvm_gemset{"ruby-1.9.3-p194@gollum":
      ensure => present,
      require => Rvm_system_ruby['ruby-1.9.3-p194'];
    }
    
    class{
	    'rvm::passenger::apache':
	    version => '3.0.18',
	    ruby_version => 'ruby-1.9.3-p194',
	    mininstances => '3',
	    maxinstancesperapp => '0',
	    maxpoolsize => '30',
	    spawnmethod => 'smart-lv2';
    }
	    
}

# Stuff that needs to be done for installing gollum
class dtg::git::gollum::main {
  vcsrepo {'/srv/gollum/':
    ensure   => latest,
    provider => 'git',
    source   => 'git://github.com/lc525/gollum-dtg.git',
    revision => 'dtg-multiwiki',
    owner    => 'lc525',
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
  apache::site{'gollum':
    source => 'puppet:///modules/dtg/gollum/apache.conf'
  }
}

