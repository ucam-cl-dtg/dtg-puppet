node 'yousense.dtg.cl.cam.ac.uk' {
    include 'dtg::minimal'
    class {'dtg::firewall::publichttp': }
    class {'dtg::firewall::publichttps': }

    # Package Setup

    package { ['nginx', 'uwsgi', 'uwsgi-plugin-python', 'uwsgi-core', 'rabbitmq-server', # Servers
               'python-pip', 'python-dev', 'tree', 'inotify-tools']:  # Tools
        ensure => installed,
    }

    class { 'dtg::yousense::apt_postgresql': stage => 'repos' }
    package { ['postgresql-9.2', 'postgresql-server-dev-9.2']:
        ensure => installed,
        require => Apt::Ppa['ppa:pitti/postgresql'],
    }

    # Files and directories for code, virtualenvs and static html
    file { ['/srv/repos', '/srv/venvs', '/srv/static', '/srv/static/yousense']:
        ensure => directory,
        owner => 'ml421',
        group => 'ml421',
    }
}

class dtg::yousense::apt_postgresql {
    apt::ppa { 'ppa:pitti/postgresql': }
}

if ( $::monitor ) {
    munin::gatherer::configure_node { 'yousense': }
}
