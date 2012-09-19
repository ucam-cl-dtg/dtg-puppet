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
