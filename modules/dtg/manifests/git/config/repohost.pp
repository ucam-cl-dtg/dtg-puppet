class dtg::git::config::repohost {
  # Git config things which only want to run on repository hosts

  # This verifies the SHA-1 checksums on all objects on pushes, which slows that down
  # but also prevents corruption of the repositories
  exec{'git receive.fsckobjects':
    command => 'git config --system receive.fsckobjects true',
    unless  => 'git config --get receive.fsckobjects',
  }
  exec{'git transfer.fsckobjects':
    command => 'git config --system transfer.fsckobjects true',
    unless  => 'git config --get transfer.fsckobjects',
  }
  exec{'git fetch.fsckobjects':
    command => 'git config --system fetch.fsckobjects true',
    unless  => 'git config --get fetch.fsckobjects',
  }
}
