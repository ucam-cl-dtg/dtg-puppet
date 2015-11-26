# DTG specific nagios config
class dtg::nagiosserver {
  class {'nagios::server': }
  nagios::service {
    'http':
      service_hostgroup_name =>'http-servers',
      service_description    =>'HTTP',
      service_check_command  => 'check_http';
    'https':
      service_hostgroup_name =>'https-servers',
      service_description    =>'HTTPS',
      service_check_command  => 'check_https';
    'https-cert':
      service_hostgroup_name =>'https-servers',
      service_description    =>'HTTPS',
      service_check_command  => 'check_https_cert';
    'ssh':
      service_hostgroup_name =>'ssh-servers',
      service_description    =>'SSH',
      service_check_command  => 'check_ssh';
    'dns':
      service_hostgroup_name =>'dns-servers',
      service_description    =>'DNS',
      service_check_command  => 'check_dns';
      
  }
}
