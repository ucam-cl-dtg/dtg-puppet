
node 'dh526-datadivider.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == 'dh526' |> { groups +>[ 'adm' ]}
}
if ( $::monitor ) {
  nagios::monitor { 'dh526-datadivider':
    parents    => '',
    address    => 'dh526-datadivider.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'dh526-datadivider': }
}
