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
    comment => 'Git Version Control'
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
