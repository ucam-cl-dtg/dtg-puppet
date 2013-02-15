node 'yousense.dtg.cl.cam.ac.uk' {
    include 'dtg::minimal'
    class {'dtg::firewall::publichttp': }
    class {'dtg::firewall::publichttps': }

    # Package Setup

    package { ['nginx', 'uwsgi', 'uwsgi-plugin-python', 'rabbitmq-server', # Servers
               'python-pip', 'python-dev', 'tree', 'htop', 'inotify-tools']:  # Tools
        ensure => installed,
    }

    class { 'dtg::yousense::apt_postgresql': stage => 'repos' }
    package { ['postgresql-9.2', 'postgresql-server-dev-9.2']:
        ensure => installed,
        require => Apt::Ppa['ppa:pitti/postgresql'],
    }

    # Files and directories for code and virtualenvs

    file { ['/srv/repos', '/srv/venvs']:
        ensure => directory,
        owner => 'ml421',
        group => 'ml421',
    }

    # Python webapp log files

    file { '/var/log/django':
        ensure => directory,
        owner => 'www-data',
        group => 'www-data',
    }
    file { ['/var/log/django/celery.log', '/var/log/django/debug.log', '/var/log/django/warn.log']:
        ensure => file,
        owner => 'www-data',
        group => 'www-data',
    }

    # Running services

}

class dtg::yousense::apt_postgresql {
    apt::ppa { 'ppa:pitti/postgresql': }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
    nagios::monitor { 'yousense':
        parents    => '',
        address    => 'yousense.dtg.cl.cam.ac.uk',
        hostgroups => [ 'ssh-servers', 'http-servers'],
    }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
    munin::gatherer::configure_node { 'yousense': }
}
