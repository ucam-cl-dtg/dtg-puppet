
node 'sak70-math.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == sak70 |> { groups +>[ 'adm' ]}
}
if ( $::monitor ) {
#  nagios::monitor { 'sak70-math':
#    parents    => 'nas04',
#    address    => 'sak70-math.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' ],
#  }
  munin::gatherer::async_node { 'sak70-math': }
}

  # mount nas04 on startup
  file_line { 'mount nas04':
    line => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/backups/deviceanalyzer /nas4 nfs defaults 0 0',
    path => '/etc/fstab',
  }
