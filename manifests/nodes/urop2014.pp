
node 'urop2014.dtg.cl.cam.ac.uk' {
  # Default config
  include 'dtg::minimal'

  # Users
  dtg::add_user { 'rmk35':
    real_name => 'Robert Kovacsics',
    groups    => [ 'adm' ],
    keys      => 'Kovacsics Robert (Alias "kr2") <kovirobi@gmail.com>',
    uid       => 232265, # From MCS linux `getent passwd rmk35`
  }
  dtg::add_user { 'tl364':
    real_name => 'Tom Lefley',
    groups    => [ 'adm' ],
    keys      => 'Tom Lefley <tl364@cam.ac.uk>',
    uid       => 204241, # From MCS linux `getent passwd tl364`
  }

  # Specific config
  class {'dtg::tomcat': version => '7'}
  class {'dtg::tomcat::raven':}
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}

}
if ( $::monitor ) {
  nagios::monitor { 'urop2014':
    parents    => 'nas04',
    address    => 'urop2014.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'urop2014': }
}
