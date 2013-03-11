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
        content => 'from="*.cam.ac.uk,*.ee" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvy3tVsuO7ibMBcJ5NY3xdc8f8yPHNYTu4VPpooDo0MiThj+BE/sSBGsklKPqw6bmPO9LBatItMUqNXWb9qdTwdAEZXGHcnxb/s2V07I6S+xN8iq10AlLTlaawPadXqK7eG1clrxCSnccZ7tJHtnID0nb2Tsh7OZATANeikJS8TEHv4/v9SWqpg2CpcG3Jd2UqQ2BBbdNTJ3t72wXl4BvaSKl+A1vPSjfZ5DqY5a5U/xZz2f3cV5CYdebzXdbVHnw8NaQzXqa8CsyVq8eLj28rb7ytGdj5HRslTuOdsXf8u2LiP+Q/oupW9giZ+DutLouSJjUMy3Wx1Mzzh83XygqeQ==',
    }
}

class dtg::yousense::apt_postgresql {
    apt::ppa { 'ppa:pitti/postgresql': }
}
