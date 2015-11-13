class dtg::git {
  # We would include gitlab here properly but doing that reqires working out
  # how to get raven auth working correctly and migrate our existing config
  # so for now just make the existing stuff work.
  # class {'dtg::git::gitlab::pre':}
  file {'/home/drt24/drt24.pub':
    ensure => file,
    owner  => 'drt24',
    group  => 'drt24',
    mode   => '0644',
    source => 'puppet:///modules/dtg/ssh/drt24.pub',
  }
  class {'dtg::git::gitolite':
    admin_key => '/home/drt24/drt24.pub',
    require   => File['/home/drt24/drt24.pub'],
  }
  class {'dtg::git::config::repohost':
  }
  class {'dtg::scm'}
  # class {'dtg::git::gitlab::main':}
}

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
# Stuff that needs to be done after gitolite install - though it should manage its requirements precisely itself
class dtg::git::gitlab::main {
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
    ensure  => directory,
    owner   => 'gitlab',
    group   => 'gitlab',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  $gitlab_from_address = $::from_address
  file {'/srv/gitlab/gitlab/config/gitlab.yml':
    ensure  => file,
    content => template('dtg/gitlab/gitlab.yml.erb'),
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  $gitlab_admin_email = $::from_address
  $gitlab_admin_password = random_password()
  # Remove the provided one and replace it with one containing
  # the correct email and a randomly generated password
  file {'/srv/gitlab/gitlab/db/fixtures/production/001_admin.rb':
    ensure  => 'absent',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  file {'/srv/gitlab/gitlab/db/fixtures/production/002_admin.rb':
    ensure  => file,
    content => template('dtg/gitlab/001_admin.rb.erb'),
    owner   => 'gitlab',
    group   => 'gitlab',
    mode    => '0600',
    replace => false,
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  # setup database stuff
  class { 'mysql::server':
    config_hash => { 'root_password' => 'mysql-password' }
  }
  class { 'mysql': }
  class { 'mysql::ruby': }
  $gitlabpassword = 'gitlabpassword'#TODO(drt24) generate this automatically without overwriting on every run
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
    unless  => 'echo "SHOW TABLES like \'users\';" | sudo -H mysql gitlabhq_production | grep users > /dev/null',
    cwd     => '/srv/gitlab/gitlab/',
    require => [File['/srv/gitlab/gitlab/config/database.yml','/srv/gitlab/gitlab/db/fixtures/production/001_admin.rb','/srv/gitlab/gitlab/db/fixtures/production/002_admin.rb'],Exec['install gitlab bundle'],Mysql::Db['gitlabhq_production']],
  }
  file {'/usr/share/gitolite/hooks/common/post-receive':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'file:///srv/gitlab/gitlab/lib/hooks/post-receive',
    require => [Package['gitolite3'],Vcsrepo['/srv/gitlab/gitlab/']],
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
    ensure  => file,
    source  => 'puppet:///modules/dtg/gitlab/unicorn.rb',
    owner   => 'gitlab',
    group   => 'gitlab',
    mode    => '0775',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
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

