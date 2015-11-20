node 'elk-elasticsearch.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class {'dtg::elk::es': }
  class {'kibana':
    port => 8080,
  }
  class { 'dtg::firewall::publichttp': }
  class { 'dtg::firewall::80to8080': }
}


if ( $::monitor ) {
  nagios::monitor { 'elk-elasticsearch':
    parents    => 'nas04',
    address    => 'elk-elasticsearch.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'kibana':
    parents                     => 'elk-elasticsearch',
    address                     => 'kibana.dtg.cl.cam.ac.uk',
    hostgroups                  => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
  munin::gatherer::configure_node { 'elk-elasticsearch': }
}
