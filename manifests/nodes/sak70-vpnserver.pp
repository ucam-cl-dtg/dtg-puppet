
node 'sak70-vpnserver.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == sak70 |> { groups +>[ 'adm' ]}

  firewall { "031-vpnserver accept udp 500":
    proto   => 'udp',
    dport   => 500,
    action  => 'accept',
  }

  firewall { "032-vpnserver accept udp 4500":
    proto   => 'udp',
    dport   => 4500,
    action  => 'accept',
  }

}
if ( $::monitor ) {
  nagios::monitor { 'sak70-vpnserver':
    parents    => 'nas04',
    address    => 'sak70-vpnserver.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'sak70-vpnserver': }
}
