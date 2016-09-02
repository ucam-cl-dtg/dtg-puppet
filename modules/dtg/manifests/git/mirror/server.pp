# A server to mirror git repositories and make them publicly accessible
class dtg::git::mirror::server {
  group {'gitmirror': ensure => present,}
  user  {'gitmirror':
    ensure  => present,
    home    => '/srv/gitmirror',
    gid     => 'gitmirror',
    comment => 'Git mirror server',
    shell   => '/bin/bash',
  }
  # Set sending address for gitmirror to dtg-infra
  file_line {'gitmirror-email':
    ensure  => present,
    path    => '/etc/email-addresses',
    line    => 'gitmirror: dtg-infra@cl.cam.ac.uk',
    require => Package['exim'],
  }

  file {'/local/data/gitmirror/':
    ensure => directory,
    owner  => 'gitmirror',
    group  => 'gitmirror',
    mode   => '2755',
  }
  file {'/srv/gitmirror/':
    ensure => link,
    target => '/local/data/gitmirror/',
  }
  file {'/srv/gitmirror/repositories/':
    ensure => directory,
    owner  => 'gitmirror',
    group  => 'gitmirror',
    mode   => '2775',
  }
  dtg::sshkeygen{'gitmirror':}
  gpg::private_key {'gitmirror':
    homedir    => '/srv/gitmirror/',
    passphrase => $::ms_gpg_passphrase,
  }
  monkeysphere::auth_capable_user {'gitmirror':
    passphrase => $::ms_gpg_passphrase,
    home       => '/srv/gitmirror/',
    require    => Gpg::Private_key['gitmirror'],
  }
  monkeysphere::trusting_user{'gitmirror':
    passphrase => $::ms_gpg_passphrase,
    require    => Monkeysphere::Auth_capable_user['gitmirror'],
    home       => '/srv/gitmirror/',
  }
  file {'/etc/systemd/system/git-daemon.service':
    ensure  => file,
    source  => 'puppet:///modules/dtg/git-daemon.service',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['git-daemon'],
    require => File['/srv/gitmirror/repositories/'],
  }
  service {'git-daemon':
    ensure  => running,
    require => [File['/etc/systemd/system/git-daemon.service']],
  }
  class {'dtg::firewall::git':}
  package {'gitweb': ensure => 'installed',}
  file {'/etc/apache2/conf.d/gitweb':
    ensure  => absent,
    require => Package['gitweb'],
  }
  file {'/etc/gitweb.conf':
    ensure  => file,
    source  => 'puppet:///modules/dtg/gitweb.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['gitweb'],
  }
  apache::site { 'gitmirror':
    source  => 'puppet:///modules/dtg/apache/gitmirror.conf',
    require => File['/srv/gitmirror/repositories/'],
  }
  #EXTENSION(drt24) this uses a dumb backend for http git but there is a clever
  # backend we could use instead which would be more efficient

  package {'git-remote-hg': ensure => 'installed',}
  file {'/srv/gitmirror/.hgrc': # Stop the use of git-remote-hg producing noise
    ensure  => file,
    owner   => 'gitmirror',
    group   => 'gitmirror',
    mode    => '0644',
    content => '[ui]
quiet = True',
  }
}
