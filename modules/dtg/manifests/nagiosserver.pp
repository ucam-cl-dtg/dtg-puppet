# DTG specific nagios config
class dtg::nagiosserver {
  class {'nagios::server': }
  nagios::hostgroup {
    'all':
      hostgroup_name  => 'all-servers',
      hostgroup_alias => 'All Servers',
      hostgroup_members         => '*';
    'ping':
      hostgroup_name  => 'ping-servers',
      hostgroup_alias => 'Pingable servers';
    'http':
      hostgroup_name  => 'http-servers',
      hostgroup_alias => 'HTTP servers';
    'https':
      hostgroup_name  => 'https-servers',
      hostgroup_alias => 'HTTPS servers';
    'ssh':
      hostgroup_name  => 'ssh-servers',
      hostgroup_alias => 'SSH servers';
    'dns':
      hostgroup_name  => 'dns-servers',
      hostgroup_alias => 'DNS servers';
    'xml':
      hostgroup_name  => 'xml-servers',
      hostgroup_alias => 'XML server socket servers';
    'nfs':
      hostgroup_name  => 'nfs-servers',
      hostgroup_alias => 'NFS servers';
    'rsyslog':
      hostgroup_name  => 'rsyslog-servers',
      hostgroup_alias => 'Rsyslog servers';
    'elasticsearch':
      hostgroup_name  => 'elasticsearch-servers',
      hostgroup_alias => 'Elasticsearch servers';
    'entropy':
      hostgroup_name  => 'entropy-servers',
      hostgroup_alias => 'Entropy servers';
    'bmc':
      hostgroup_name  => 'bmcs',
      hostgroup_alias => 'BMCs';
  }
  ->
  nagios::service {
    'ping':
      service_hostgroup_name => 'ping-servers',
      service_description    => 'PING',
      service_check_command  => 'check_ping!500.0,20%!1000.0,60%';
    'http':
      service_hostgroup_name => 'http-servers',
      service_description    => 'HTTP',
      service_check_command  => 'check_http';
    'https':
      service_hostgroup_name => 'https-servers',
      service_description    => 'HTTPS',
      service_check_command  => 'check_https';
    'https-cert':
      service_hostgroup_name => 'https-servers',
      service_description    => 'HTTPS Certificate',
      service_check_command  => 'check_https_cert';
    'ssh':
      service_hostgroup_name =>'ssh-servers',
      service_description    =>'SSH',
      service_check_command  => 'check_ssh';
    'dns':
      service_hostgroup_name =>'dns-servers',
      service_description    =>'DNS',
      service_check_command  => 'check_dns';
    'xml-server-socket':
      service_hostgroup_name =>'xml-servers',
      service_description    =>'XML',
      service_check_command  => 'check_tcp!2468';
    'nfs':
      service_hostgroup_name =>'nfs-servers',
      service_description    =>'NFS',
      service_check_command  => 'check_tcp!2049';
    'rsyslog':
      service_hostgroup_name =>'rsyslog-servers',
      service_description    =>'rsyslog',
      service_check_command  => 'check_tcp!514';
    'elasticsearch':
      service_hostgroup_name =>'elasticsearch-servers',
      service_description    =>'Elasticsearch',
      service_check_command  => 'check_tcp!9200';
    'entropy':
      service_hostgroup_name =>'entropy-servers',
      service_description    =>'Entropy',
      service_check_command  => 'check_tcp!7776';
    'bmc':
      service_hostgroup_name =>'bmcs',
      service_description    =>'BMCs',
      service_check_command  => 'check_tcp!623';
  }
}
