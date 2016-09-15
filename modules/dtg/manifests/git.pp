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
  class {'dtg::scm':}
  # class {'dtg::git::gitlab::main':}
}
