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
