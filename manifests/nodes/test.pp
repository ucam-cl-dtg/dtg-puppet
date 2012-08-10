node 'test-puppet.dtg.cl.cam.ac.uk' {
  include minimal
}
if ( $::fqdn == $::nagios_server ) {
  nagios_monitor { 'test-puppet': }
}
