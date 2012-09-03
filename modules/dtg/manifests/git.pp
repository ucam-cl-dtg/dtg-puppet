class dtg::git {
  $packages = ['gitolite']
  package {$packages :
    ensure => installed,
  }
  group {'git': ensure => present,}
  user {'git':
    ensure  => present,
    home    => '/srv/git/',
    gid     => 'git',
    comment => 'Git Version Control',
    shell   => '/bin/bash',
  }
  file {'/local/data/git':
    ensure => directory,
    owner  => 'git',
    group  => 'git',
    mode   => '0755',
  }
  file {'/srv/git/':
    ensure => link,
    target => '/local/data/git/',
  }
  # Bootstrap admin key
  file {'/srv/git/drt24.pub':
    ensure => file,
    source => 'puppet:///modules/dtg/ssh/drt24.pub',
  }
  exec {'setup-gitolite':
    command => 'sudo -H -u git -g -git gl-setup drt24.pub',
    cwd     => '/srv/git/',
    creates => '/srv/git/repositories/',
  }
  #TODO(drt24) setup backups and restore from backups
}
class dtg::git::labhq {
  $packages = ['ruby']
  package {$packages :
    ensure => installed,
  }
  group {'gitlab':}
  user {'gitlab':
    gid      => 'gitlab',
    groups   => 'git',
    comment  => 'gitlab system',
    password => '!',#disable login
  }
  
}
