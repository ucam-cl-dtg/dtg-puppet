class aptrepository($repository) {
  # Manage apt sources lists
  #  Use puppet to manage sources.list but allow manual stuff inside sources.list.d
  class { 'apt':
    purge => { 'sources.list'    => true },
    stage => $stage,
  }
  if $::operatingsystem == 'Ubuntu' {
    # Include main repository
    apt::source { 'main':
      location => $repository,
      repos    => 'main restricted universe multiverse',
    }
    # Security updates
    apt::source { 'security':
      location => $repository,
      release  => "${::lsbdistcodename}-security",
      repos    => 'main restricted universe multiverse',
    }
    apt::source { 'security-failsafe':
      location => 'http://security.ubuntu.com/ubuntu',
      release  => "${::lsbdistcodename}-security",
      repos    => 'main restricted universe multiverse',
    }
    # Bugfix updates
    apt::source { 'updates':
      location => $repository,
      release  => "${::lsbdistcodename}-updates",
      repos    => 'main restricted universe multiverse',
    }
  }
  if $::operatingsystem == 'Debian' {
    apt::source {'main':
      location => $repository,
      repos    => 'main contrib non-free',
    }
    apt::source {'security-failsafe':
      location => 'http://security.debian.org/debian-security',
      release  => "${::lsbdistcodename}/updates",
      repos    => 'main contrib non-free',
    }
    apt::source {'backports':
      location => $repository,
      release  => "${::lsbdistcodename}-backports",
      repos    => 'main contrib non-free',
    }
    apt::source {'updates':
      location => $repository,
      release  => "${::lsbdistcodename}-updates",
      repos    => 'main contrib non-free',
    }
  }
}
