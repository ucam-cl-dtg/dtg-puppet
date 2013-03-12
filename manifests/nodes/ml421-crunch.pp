node 'ml421-crunch' {
    include 'dtg::minimal'
    class {'dtg::firewall::publichttp': }
    class {'dtg::firewall::publichttps': }

    # Package Setup

    package { ['python-pip', 'python-dev', 'tree', 'htop', 'inotify-tools']:  # Tools
        ensure => installed,
    }

    class { 'dtg::yousense::apt_postgresql': stage => 'repos' }
    package { ['postgresql-9.2', 'postgresql-server-dev-9.2']:
        ensure => installed,
        require => Apt::Ppa['ppa:pitti/postgresql'],
    }

    # Tartu people's account for sending me data
    group { 'positium': ensure => present,}
    user { 'positium':
        ensure => present,
        gid => 'positium',
        groups => ['positium'],
    }
    file { ['/home/positium', '/home/positium/.ssh']:
        ensure => directory,
        owner => 'positium',
        group => 'positium',
        mode => '0700',
    }
    file { '/home/positium/.ssh/authorized_keys':
        ensure => file,
        mode => '0600',
        content => 'from="*.cam.ac.uk,*.ee" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYc3EzVVeQZAiNHyk1v5f8ckOhwjk1I6B362I7Wy13MKNxBb+8KN2dKH7qFWPN5nj1e8tU7l3JoXcoWS9LvrhigfJXmyZh4No5L8Xrr0hfD0j6UXCq5nlsBFJW/t88RogNxdLwYVrJxA/5EdJJFxKlmUw8GtdmVuYljqluqn7eOLxL2ZxsC/MVTMQcMlNLXEEzBGvmtpLlEhjqO0aYsSXu1Ol2LxrJF+pyhidLnGMno76PytSGyWuOs6qpztSkBXprcr0RFYjV8l5XJjvW03enY6K9ShqDoGE0QnDLxKScjmzJ/FshxbNljGqKa54fb+K9uWLiAWwk4TqwHOjT3doV',
    }

}

