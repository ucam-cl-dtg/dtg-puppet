node 'elk-logstash.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class { 'dtg::firewall::rsyslog': }
  class { 'dtg::elk::logs': }
}


if ( $::monitor ) {
  nagios::monitor { 'elk-logstash':
    parents    => 'nas04',
    address    => 'elk-logstash.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'rsyslog-servers' ],
  }
  munin::gatherer::configure_node { 'elk-logstash': }
}
