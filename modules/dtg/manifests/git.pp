class dtg::git {
  # Setup gitolite package
  $gitolitepackages = ['gitolite']
  package {$gitolitepackages :
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
  # Setup gitlab
  $gitlabpackages = ['ruby1.9.1', 'ruby1.9.1-dev', 'ruby-bundler', 'python-pygments', 'libicu-dev', 'libmysqlclient-dev', 'ruby-sqlite3', 'libsqlite3-dev', 'libxslt-dev','libxml2-dev', 'libcurl4-openssl-dev', 'libreadline6-dev', 'libssl-dev', 'libmysql++-dev', 'redis-server', 'python-dev', 'libyaml-dev', 'make', 'build-essential']
  package {$gitlabpackages :
    ensure => installed,
  }
  # Use ruby 1.9.1 to provide ruby
  dtg::alternatives{'ruby':
    linkto => '/usr/bin/ruby1.9.1',
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
  file {'/srv/gitlab/.ssh/':
    ensure => directory,
    owner  => 'gitlab',
    group  => 'gitlab',
    mode   => '0700',
  }
  exec {'gen-gitlab-sshkey':
    command => 'sudo -H -u gitlab -g gitlab ssh-keygen -q -N "" -t rsa -f /srv/gitlab/.ssh/id_rsa',
    creates => '/srv/gitlab/.ssh/id_rsa',
    require => File['/srv/gitlab/.ssh/'],
  }
  # Setup gitolite
  # Bootstrap admin key
#  file {'/srv/git/drt24.pub':
#    ensure => file,
#    source => 'puppet:///modules/dtg/ssh/drt24.pub',
#  }
  file {'/srv/git/gitlab.pub':
    ensure  => file,
    source  => 'file:///srv/gitlab/.ssh/id_rsa.pub',
    owner   => 'gitlab',
    group   => 'git',
    mode    => '0744',
    require => Exec['gen-gitlab-sshkey'],
  }
  file {'/usr/share/gitolite/conf/example.gitolite.rc':
    ensure => file,
    source => 'puppet:///modules/dtg/example.gitolite.rc',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['gitolite'],
  }
  exec {'setup-gitolite':
    command => 'sudo -H -u git -g git gl-setup gitlab.pub',
    cwd     => '/srv/git/',
    creates => '/srv/git/repositories/',
    require => File['/srv/git/gitlab.pub', '/usr/share/gitolite/conf/example.gitolite.rc'],
  }
  # Install gitlab
  package {'charlock_holmes':
    ensure   => 'latest',
    provider => 'gem',
    require  => Dtg::Alternatives['ruby'],
  }
  vcsrepo {'/srv/gitlab/gitlab/':
    ensure   => latest,
    provider => 'git',
    source   => 'git://github.com/gitlabhq/gitlabhq.git',
    revision => 'stable',
    owner    => 'gitlab',
    group    => 'gitlab',
    require  => File['/srv/gitlab/'],
  }
  file {'/srv/gitlab/gitlab/tmp/':
    ensure => directory,
    owner  => 'gitlab',
    group  => 'gitlab',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  $gitlab_from_address = $::from_address
  file {'/srv/gitlab/gitlab/config/gitlab.yml':
    ensure  => file,
    content => template('dtg/gitlab/gitlab.yml.erb'),
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  # setup database stuff
  class { 'mysql::server':
    config_hash => { 'root_password' => 'mysql-password' }
  }
  class { 'mysql': }
  class { 'mysql::ruby': }
  $gitlabpassword = "gitlabpassword"#TODO(drt24) generate this automatically without overwriting on every run
  mysql::db { 'gitlabhq_production':
    user     => 'gitlab',
    password => $gitlabpassword,
    host     => 'localhost',
    grant    => ['all'],
    require  => Class['mysql::server'],
  }
  class { 'mysql::backup':
    backupuser     => 'mysqlbackup',
    backuppassword => 'mysqlbackup',
    backupdir      => '/var/backups/mysql/',
  }
  file {'/srv/gitlab/gitlab/config/database.yml':
    ensure  => file,
    content => template('dtg/gitlab/database.yml.erb'),
    owner   => 'gitlab',
    group   => 'gitlab',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  exec {'install gitlab bundle':
    command => 'sudo -u gitlab -g gitlab -H bundle install --without development test --deployment',
    creates => '/srv/gitlab/gitlab/vendor/bundle/',
    cwd     => '/srv/gitlab/gitlab/',
    require => [File['/srv/gitlab/gitlab/config/gitlab.yml'],Class['mysql::ruby'],Package['libmysqlclient-dev','make','build-essential'],Dtg::Alternatives['ruby']],
  }
  exec {'setup gitlab database':
    command => 'sudo -u gitlab -g gitlab -H bundle exec rake gitlab:app:setup RAILS_ENV=production',
    unless  => 'false',#TODO(drt24)
    cwd     => '/srv/gitlab/gitlab/',
    require => [File['/srv/gitlab/gitlab/config/database.yml'],Exec['install gitlab bundle'],Mysql::Db['gitlabhq_production']],
  }
  file {'/usr/share/gitolite/hooks/common/post-receive':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'file:///srv/gitlab/gitlab/lib/hooks/post-receive',
    require => [Package['gitolite'],Vcsrepo['/srv/gitlab/gitlab/']],
  }
  exec {'start gitlab':
    command => 'sudo -u gitlab -g gitlab -H bundle exec rails s -e production -d',
    unless  => 'ps aux | grep `cat /srv/gitlab/gitlab/tmp/pids/server.pid` >/dev/null',
    cwd     => '/srv/gitlab/gitlab/',
    require => Exec['install gitlab bundle','setup gitlab database'],
  }
  exec {'run resque process':
    command => 'sudo -u gitlab -g gitlab -H ./resque.sh',
    unless  => 'ps aux | grep `cat /srv/gitlab/gitlab/tmp/pids/resque_worker.pid` >/dev/null',
    cwd     => '/srv/gitlab/gitlab/',
    require => Exec['start gitlab'],
  }
  file {'/srv/gitlab/gitlab/config/unicorn.rb':
    ensure => file,
    source => 'puppet:///modules/dtg/gitlab/unicorn.rb',
    owner  => 'gitlab',
    group  => 'gitlab',
    mode   => '0775',
  }
  exec {'run unicorn process':
    command => 'sudo -u gitlab -g gitlab -H bundle exec unicorn_rails -c config/unicorn.rb -E production -D',
    unless  => 'ps aux | grep `cat /srv/gitlab/gitlab/tmp/pids/unicorn.pid` >/dev/null',
    cwd     => '/srv/gitlab/gitlab/',
    require => [Exec['start gitlab'],File['/srv/gitlab/gitlab/config/unicorn.rb']],
  }
  apache::site{'gitlab':
    source => 'puppet:///modules/dtg/gitlab/apache.conf'
  }
}
class git::mirror::server {
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
    mode   => '2775',
  }
  file {'/srv/gitmirror/':
    ensure => link,
    target => '/local/data/gitmirror/',
  }
}
