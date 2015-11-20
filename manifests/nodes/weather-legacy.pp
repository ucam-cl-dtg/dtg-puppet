node 'weather-legacy.dtg.cl.cam.ac.uk' {
  class {'dtg::minimal':}
  class {'dtg::firewall::publichttp':}

  User<|title == 'dwt27' |> { groups +>[ 'adm' ]}
}

# Disable monitoring until things are more stable:
#if ( $::monitor ) {
#  nagios::monitor { 'weather-legacy':
#    parents    => 'nas04',
#    address    => 'weather-legacy.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers', 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'weather-legacy': }
#}
