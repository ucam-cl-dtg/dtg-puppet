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
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDM299YV9WPk2Tfvajj79gDPG09BEJ2B1vBpEBPGG2ri1erlHYfN7UCHwGQITh1adBxt0CzuDaTU6AtTxohWvRNvUj8hjVOCjeIb0093Hva0q2yHBNAJ/Ac2bAfDNn28p6DZYTS6nYRxqBNAJbbku3AL9Hvr7YxLLJpYphCT9ro02WuXjOsSM3ixLFnNRDzPxrXm1Uibbhe3e0Ri/3jZToA8zinB5Po5UCIXpnT7phBAyysIZ6NHe0y8ExD5j544l/WZ84QiG/r1vBR9ROgciZ+vTgFCU0j42DiPIwgBuoj2i0/7kLvgSMxrhx4Se0D1iT4xDcTqgTB9AOkjVoreMYJ',
    user => 'dac53',
    type => 'ssh-rsa',
  }
}
if ( $::monitor ) {
  nagios::monitor { 'dac53':
    parents    => 'nas04',
    address    => 'dac53.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'dac53': }
}
