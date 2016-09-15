
node /urop2014(-\d+)?.dtg.cl.cam.ac.uk/ {
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
  dtg::add_user { 'ird28':
    real_name => 'Isaac Dunn',
    groups    => [ 'adm' ],
    keys      => 'Isaac Dunn <ird28@cam.ac.uk>',
    uid       => 232976, # From MCS linux `getent passwd ird28`
  }
  dtg::add_user { 'rds46':
    real_name => 'Raahil Shah',
    groups    => [ 'adm' ],
    keys      => 'Raahil Shah (ssh) <rds46@cam.ac.uk>',
    uid       => 232161, # From MCS linux `getent passwd rds46`
  }
  dtg::add_user { 'as2388':
    real_name => 'Alexander Simpson',
    groups    => [ 'adm' ],
    keys      => 'Alexander Simpson (ssh) <as2388@cam.ac.uk>',
    uid       => 231203, # From MCS linux `getent passwd as2388`
  }
  dtg::add_user { 'kls82':
    real_name => 'Katie Scott',
    groups    => [ 'adm' ],
    keys      => 'Katie Scott (ssh) <kls82@cam.ac.uk>',
    uid       => 233375, # From MCS linux `getent passwd kls82`
  }

  User<|title == sac92 |> { groups +>[ 'adm' ]}

  # Specific config
  class {'dtg::tomcat': version => '8'}
  class {'dtg::tomcat::raven':}
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}

}
if ( $::monitor ) {
  munin::gatherer::async_node { 'urop2014': }
}
