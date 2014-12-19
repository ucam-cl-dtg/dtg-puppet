class dtg::git::config {
  exec{'git graph':
    command => 'git config --system --add alias.graph \'log --graph --date-order -C -M --pretty=format:"<%h> %ad [%an] %Cgreen%d%Creset %s" --all --date=short\'',
    unless => 'git config --get alias.graph',
  }
  dtg::git::config::user{'root':
    real_name => 'DTG Infrastructure',
    email     => 'dtg-infra@cl.cam.ac.uk',
  }
}
class dtg::git::config::repohost {
  # Git config things which only want to run on repository hosts

  # This verifies the SHA-1 checksums on all objects on pushes, which slows that down
  # but also prevents corruption of the repositories
  exec{'git receive.fsckobjects':
    command => 'git config --system receive.fsckobjects true',
    unless => 'git config --get receive.fsckobjects',
  }
  exec{'git transfer.fsckobjects':
    command => 'git config --system transfer.fsckobjects true',
    unless => 'git config --get transfer.fsckobjects',
  }
  exec{'git fetch.fsckobjects':
    command => 'git config --system fetch.fsckobjects true',
    unless => 'git config --get fetch.fsckobjects',
  }
}
# $name is the username, $real_name is the name the user is generally known by
# $email is their email address
define dtg::git::config::user ($real_name, $email) {
  $user = $name
  exec{"git ${user} user.name":
    command => "sudo -H -u ${user} git config --global --add user.name '${real_name}'",
    unless  => "sudo -H -u ${user} git config --get user.name",
  }
  exec{"git ${user} user.email":
    command => "sudo -H -u ${user} git config --global --add user.email '${email}'",
    unless  => "sudo -H -u ${user} git config --get user.email",
  }
}
