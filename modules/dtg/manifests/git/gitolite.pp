# admin_key is the key to use for the first gitolite admin
# repo_group is the group to use for the repositories
# repo_mode the mode to make the repositories parent directory
# repo_recurse whether the permission should be applied recursively
class dtg::git::gitolite ($admin_key, $repo_group = 'git', $repo_mode = undef, $repo_recurse = false){
  # Setup gitolite package
  $gitolitepackages = ['gitolite3']
  package {$gitolitepackages :
    ensure => installed,
  }
  group {'git': ensure => present,}
  user {'git':
    ensure   => present,
    home     => '/srv/git/',
    gid      => 'git',
    comment  => 'Git Version Control',
    shell    => '/bin/bash',
    password => '*',#no password but key based login
  }
  file { [ '/local', '/local/data' ]:
    ensure => directory,
  }
  file {'/local/data/git':
    ensure  => directory,
    owner   => 'git',
    group   => 'git',
    mode    => '2755',
    require => File['/local','/local/data'],
  }
  file {'/srv/git/':
    ensure => link,
    target => '/local/data/git/',
  }
  #TODO(drt24)  restore from backups
  file {'/usr/share/gitolite/hooks/common/post-receive':
    ensure  => file,
    source  => 'puppet:///modules/dtg/post-receive-email.hook',
    mode    => '0755',
    require => Package['gitolite3'],
  }
  exec {'setup-gitolite':
    command => "sudo -H -u git -g git gitolite setup -pk ${admin_key}",
    cwd     => '/srv/git/',
    creates => '/srv/git/repositories/',
    require => File[$admin_key],
  }
  file {'/srv/git/repositories':
    ensure  => directory,
    mode    => $repo_mode,
    owner   => 'git',
    group   => $repo_group,
    recurse => $repo_recurse,
    require => Exec['setup-gitolite'],
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
  # Allow backups to be taken of the git repositories
  dtg::backup::serversetup {'gitolite repositories':
    backup_directory   => '/srv/git/repositories/',
    script_destination => '/srv/git/backup',
    user               => 'git',
    home               => '/srv/git/',
    require            => File['/srv/git/repositories'],
  }
}
