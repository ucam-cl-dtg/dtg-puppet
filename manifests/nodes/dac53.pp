# VM for dac53's Mphil project
node "dac53.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  dtg::add_user { 'dac53':
    real_name => 'Diana Crisan',
    groups    => [ 'adm' ],
    keys      => '',
    uid       => 3252,
  } ->
  ssh_authorized_key {'dac53 key':
    ensure => present,
    key => '',
    user => 'dac53',
    type => 'ssh-rsa',
  }
}
if ( $::monitor ) {
  nagios::monitor { 'dac53':
    parents    => '',
    address    => 'dac53.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'dac53': }
}
