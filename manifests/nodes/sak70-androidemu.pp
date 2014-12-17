
node 'sak70-androidemu.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == sak70 |> { groups +>[ 'adm' ]}
}
if ( $::monitor ) {
  nagios::monitor { 'sak70-androidemu':
    parents    => 'nas04',
    address    => 'sak70-androidemu.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'sak70-androidemu': }
}
