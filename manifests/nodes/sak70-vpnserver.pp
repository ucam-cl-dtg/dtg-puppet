
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

  firewall { "033-vpnserver accept esp":
    proto   => 'esp',
    action  => 'accept',
  }

  firewall { "034-vpnserver accept l2tp over ipsec":
    proto         => 'udp',
    ipsec_policy  => 'ipsec',
    ipsec_dir     => 'in',
    dport         => 'l2tp',
    action        => 'accept',
  } 

  firewall { "100-vpnserver accept 8080 over vpn":
    proto  => 'tcp',
    dport  => 8080,
    dest   => '192.168.111.1',
    action => 'accept',
  }    

  firewall { "998 log dropped packets":
    proto => 'all',
    jump  => 'LOG',
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
