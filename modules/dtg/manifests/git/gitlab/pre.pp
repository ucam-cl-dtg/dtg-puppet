# Some things need to be done before gitolite is installed (key generation)
class dtg::git::gitlab::pre {
  # Setup gitlab
  $gitlabpackages = ['ruby1.9.1', 'ruby1.9.1-dev', 'ruby-bundler', 'python-pygments', 'libicu-dev', 'libmysqlclient-dev', 'ruby-sqlite3', 'libsqlite3-dev', 'libxslt1-dev','libxml2-dev', 'libcurl4-openssl-dev', 'libreadline6-dev', 'libssl-dev', 'libmysql++-dev', 'redis-server', 'python-dev', 'libyaml-dev', 'make', 'build-essential']
  package {$gitlabpackages :
    ensure => installed,
  }
  # Use ruby 1.9.1 to provide ruby
  dtg::alternatives{'ruby':
    linkto  => '/usr/bin/ruby1.9.1',
    require => Package['ruby1.9.1','ruby1.9.1-dev'],
  }
  group {'gitlab': ensure => 'present',}
  user {'gitlab':
    ensure   => 'present',
    gid      => 'gitlab',
    groups   => 'git',
    comment  => 'Gitlab System',
    home     => '/srv/gitlab/',
    password => '!',#disable login
  }
  file {'/local/data/gitlab':
    ensure => directory,
    owner  => 'gitlab',
    group  => 'gitlab',
    mode   => '2755',
  }
  file {'/srv/gitlab/':
    ensure => link,
    target => '/local/data/gitlab/',
  }
  dtg::sshkeygen{'gitlab':}
  # Setup gitolite
  # Bootstrap admin key
  file {'/srv/gitlab/gitlab.pub':
    ensure  => file,
    source  => 'file:///srv/gitlab/.ssh/id_rsa.pub',
    owner   => 'gitlab',
    group   => 'git',
    mode    => '0744',
    require => Dtg::Sshkeygen['gitlab'],
  }
}
