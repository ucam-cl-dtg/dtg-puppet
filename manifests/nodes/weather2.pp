node /^weather2(-dev)?.dtg.cl.cam.ac.uk$/ {
  class { 'dtg::minimal': }
  if ( $::hostname == "weather2" ) {
    # Do not open up firewall on weather2-dev
    class {'dtg::firewall::publichttp':}
  }

  User<|title == 'dwt27' |> { groups +>[ 'adm' ]}
}

# Disable monitoring until things are more stable:
#if ( $::monitor ) {
#  # Note: do not monitor weather2-dev
#  nagios::monitor { 'weather2':
#    parents    => 'nas04',
#    address    => 'weather2.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers', 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'weather2': }
#}
