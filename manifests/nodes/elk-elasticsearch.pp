node 'elk-elasticsearch.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class {'dtg::elk::es': }
  class { 'dtg::firewall::publichttp': }
  class { 'dtg::firewall::80to8080': }

  file{'/var/run/kibana/':
    ensure =>  directory,
    owner  => 'kibana',
    group  => 'kibana',
    mode   => '0755',
  }
  ->
  class {'kibana':
    port => 8080,

    # Override the default pid file location of /var/run/kibana.pid
    # as Kibana doesn't run as root and cannot create its pid
    # file due to permissions on /var/run
    pid_file => '/var/run/kibana/kibana.pid',
  }


}


if ( $::monitor ) {
  nagios::monitor { 'elk-elasticsearch':
    parents    => 'nas04',
    address    => 'elk-elasticsearch.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers',  'elasticsearch-servers' ],
  }
  nagios::monitor { 'kibana':
    parents                     => 'elk-elasticsearch',
    address                     => 'kibana.dtg.cl.cam.ac.uk',
    hostgroups                  => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
  munin::gatherer::configure_node { 'elk-elasticsearch': }
}
