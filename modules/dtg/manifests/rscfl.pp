class dtg::rscfl {
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::avahi':}

  class {'distcc':
    listen_ip_range => $dtg_subnet,
    listen_on_ip    => '127.0.0.1',
  }

  $rscfl_packages = ['python-jinja2', 'systemtap', 'build-essential', 'cmake',
                    'clang', 'python-pip', 'ccache']
  package{$rscfl_packages:
    ensure => installed,
  }

  # Clone upstream linux
  vcsrepo { '/srv/linux-stable':
    ensure   => present,
    provider => git,
    source   => 'git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git',
    owner    => 'root',
    group    => 'rscfl',
    revision => 'v4.0'
  }

  # Setup bash profile for all users

  file {'/etc/.profile':
    source => 'puppet:///modules/dtg/.profile',
    ensure => present,
  }

}
