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
