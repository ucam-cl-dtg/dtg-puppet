# The title is the username, the email will be used to tell the user their password
# groups may be provided to specify additional groups such as adm
# TODO(drt24) monkeysphere integration
define dtg::add_user ( $email, $groups = '') {

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

    # Required in the setuserpassword script
    package { 'apg' : ensure => installed }

    file { "/usr/local/sbin/setuserpassword":
        ensure  => file,
        mode    => 755,
        owner   => root,
        group   => root,
        source  => "puppet:///modules/dtg/sbin/setuserpassword",
        require => Package['apg'],
    }

    exec { "setuserpassword $username":
         refreshonly     => true,
         subscribe       => User[$username],
         unless          => "grep $username /etc/shadow | cut -f 2 -d : | grep -v '!'",
         require         => File["/usr/local/sbin/setuserpassword"],
    }

}
