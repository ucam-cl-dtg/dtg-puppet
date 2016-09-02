# Mirror to $name the repository accessible at $source
# Name is the repository name to use
define dtg::git::mirror::repo ($source) {
  vcsrepo {"/srv/gitmirror/repositories/${name}.git":
    ensure   => 'bare',
    provider => 'git',
    source   => $source,
    owner    => 'gitmirror',
    group    => 'gitmirror',
    user     => 'gitmirror',
    require  => File['/srv/gitmirror/repositories'],
  }
  cron {"gitmirror-mirror-${name}":
    ensure  => present,
    command => "cd /srv/gitmirror/repositories/${name}.git && nice git fetch --quiet origin master:master && nice git update-server-info",
    user    => 'gitmirror',
    hour    => cron_hour("${name}-mirror"),
    minute  => cron_minute("${name}-mirror"),
    require => Vcsrepo["/srv/gitmirror/repositories/${name}.git"],
  }
  cron {"gitmirror-gc-${name}":
    ensure  => present,
    command => "cd /srv/gitmirror/repositories/${name}.git && nice git fsck --strict && nice git repack -a -d --depth=100 --window=100",
    user    => 'gitmirror',
    hour    => cron_hour($name),
    minute  => cron_minute($name),
    require => Vcsrepo["/srv/gitmirror/repositories/${name}.git"],
  }
}
