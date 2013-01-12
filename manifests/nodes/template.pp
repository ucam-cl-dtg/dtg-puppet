/* Replace HOSTNAME with the machines hostname and add additional config into
 the node section.

node "HOSTNAME.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'HOSTNAME':
    parents    => '',
    address    => 'HOSTNAME.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'HOSTNAME': }
}
*/
