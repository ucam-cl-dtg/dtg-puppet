# The title is the username, the email will be used to contact the user
# groups may be provided to specify additional groups such as adm
# keys are the array of character for character gpg key user ids for the user
#  these will be use with monkeyshpere to provide ssh keys
define dtg::add_user ( $real_name, $groups = '', $keys = undef, $uid, $dot_file_repo = undef, $user_whitelist = undef) {

    $username = $title
    $email = "${username}@cam.ac.uk"

  if (! $user_whitelist or $username in $user_whitelist) {
    
    user { $username:
        ensure     => present,
        comment    => "${real_name} <${email}>",
        home       => "/home/${username}",
        shell      => '/bin/bash',
        groups     => $groups,
        uid        => $uid,
        membership => 'inclusive',
        password   => '*',
    }

    group { $username:
        require => User[$username],
        gid     => $uid,
    }

    file { "/home/${username}/":
        ensure  => directory,
        owner   => $username,
        group   => $username,
        mode    => '0755',
        require => [ User[$username], Group[$username] ],
    }

    # If the user has gpg key ids specified then use them
    if ($keys != undef) {
        monkeysphere::authorized_user_ids { $username:
            user_ids => $keys,
            dest_dir => "/home/${username}/.monkeysphere",
        }
    }
    # Configure git
    dtg::git::config::user{$username:
        email     => $email,
        real_name => $real_name,
        require   => File["/home/${username}/"],
    }

    # If the user has a dotfile repo
    if ($dot_file_repo != undef) {
        vcsrepo { "/home/${username}/.dot_files/":
            ensure   => latest,
            provider => git,
            source   => $dot_file_repo,
            user     => $username,
            require  => [File["/home/${username}/"], User[$username]],
        } ->
        file { "/home/${username}/.profile":
            ensure => link,
            target => "/home/${username}/.dot_files/.profile",
            owner  => $username,
        }
    }
  }
  else {
    user { $username:
      ensure     => absent
    }
    ->
    group { $username:
      ensure     => absent
    }
  }
}
