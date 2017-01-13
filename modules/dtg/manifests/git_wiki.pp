# git_wiki.pp
# Maintainer: Lucian Carata <lc525@cam.ac.uk>
#
# This installs dtg-gollum (https://github.com/ucam-cl-dtg/gollum-dtg),
# the DTG wiki server and corresponding git-backed wikis
#

class dtg::git_wiki {
  dtg::sudoers_group{ 'wiki-adm':
    group_name => 'wiki-adm',
  }

  file {'/home/lc525/lc525.pub':
    ensure => file,
    owner  => 'lc525',
    group  => 'lc525',
    mode   => '0644',
    source => 'puppet:///modules/dtg/ssh/lc525.pub',
  }

  class {'dtg::git::gitolite':
    admin_key    => '/home/lc525/lc525.pub',
    repo_group   => 'www-data',
    repo_mode    => '0775',
    repo_recurse => true,
    require      => File['/home/lc525/lc525.pub'],
  }

  class {'dtg::git::gollum::pre':}
  class {'dtg::git::gollum::main':}

  dtg::backup::serversetup {'wiki':
    backup_directory   => '/local/data/git',
    script_destination => '/srv/git/wiki-backup',
    user               => 'git',
    home               => '/srv/git/',
  }

  package { 'python3 python3-requests':
    ensure => installed,
  }->
  user {'lunch':
    ensure     => present,
    home       => '/srv/lunch',
    managehome => true,
  }->
  vcsrepo { '/srv/lunch':
    ensure   => present,
    provider => git,
    source   => 'ssh://git@gitlab.dtg.cl.cam.ac.uk:tb403/dtg-lunch-notify.git',
  }->
  cron { 'dtg-lunch':
    command => '/usr/bin/python3 /srv/lunch/dtg-lunch.py',
    user    => 'lunch',
    hour    => 9,
    minute  => 0,
  }
}

if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'wiki':
    user    => 'git',
    host    => 'wiki.dtg.cl.cam.ac.uk',
    weekday => 'Sunday',
    require => Class['dtg::backup::host'],
  }
}
