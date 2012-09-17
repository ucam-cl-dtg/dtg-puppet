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
  package {'git-daemon-run': ensure => 'present',}
  file {'/etc/service/git-daemon/run':
    ensure => file,
    source => 'puppet:///modules/dtg/git-daemon-run',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  service {'git-daemon':
    ensure => running,
    require => [Package['git-daemon-run'],File['/etc/service/git-daemon/run']],
  }
  class {'dtg::firewall::git':}
 #TODO(drt24) Make these repositories publicly accessible via http: protocol and with a pretty website for browsing
}

# Mirror to $name the repository accessible at $source
# Name is the repository name to use
define dtg::git::mirror::repo ($source) {
  vcsrepo {"/srv/gitmirror/repositories/${name}.git":
    ensure   => latest,
    provider => 'git',
    source   => $source,
    owner    => 'gitmirror',
    group    => 'gitmirror',
    user     => 'gitmirror',
    require  => File['/srv/gitmirror/repositories'],
  }
  cron {"gitmirror-mirror-${name}":
    ensure  => present,
    command => "cd /srv/gitmirror/repositories/${name}.git && git fetch --all --quiet --tags",
    user    => 'gitmirror',
    minute  => cron_minute("${name}-mirror"),
    require => Vcsrepo["/srv/gitmirror/repositories/${name}.git"],
  }
  cron {"gitmirror-gc-${name}":
    ensure  => present,
    command => "cd /srv/gitmirror/repositories/${name}.git && git repack -a -d --depth=100 --window=100",
    hour    => cron_hour($name),
    minute  => cron_minute($name),
    require => Vcsrepo["/srv/gitmirror/repositories/${name}.git"],
  }
}
