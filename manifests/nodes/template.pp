/* Replace HOSTNAME with the machines hostname and add additional config into
 the node section.

node 'HOSTNAME.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
}
if ( $::monitor ) {
  nagios::monitor { 'HOSTNAME':
    parents    => '',
    address    => 'HOSTNAME.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'HOSTNAME': }
}
*/
