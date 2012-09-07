# The title is the username, the email will be used to tell the user their password
# groups may be provided to specify additional groups such as adm
# keys are the array of character for character gpg key user ids for the user
#  these will be use with monkeyshpere to provide ssh keys
define dtg::add_user ( $email, $groups = '', $keys = undef) {

    $username = $title

    user { $username:
        comment => "$email",
        home    => "/home/$username",
        shell   => "/bin/bash",
        groups  => $groups,
        membership => minimum,
    }

    group { $username:
        require => User[$username]
    }

    file { "/home/$username/":
        ensure  => directory,
        owner   => $username,
        group   => $username,
        mode    => 755,
        require => [ User[$username], Group[$username] ],
    }

    exec { "setuserpassword $username":
         refreshonly     => true,
         subscribe       => User[$username],
         unless          => "grep $username /etc/shadow | cut -f 2 -d : | grep -v '!'",
         require         => File["/usr/local/sbin/setuserpassword"],
    }

    # If the user has gpg key ids specified then use them
    if ($keys != undef) {
        monkeysphere::authorized_user_ids { "$username":
            user_ids => $keys,
            dest_dir => "/home/$username/.monkeysphere",
        }
    }

}
