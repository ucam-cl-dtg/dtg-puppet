
node /gmp37(-\d+)?/ {
  include 'dtg::minimal'
  dtg::add_user { 'gmp37':
    real_name => 'George Panagopoulos',
    groups    => [ 'adm' ],
    keys      => 'George Panagopoulos (DMGT test) <gmp37@cam.ac.uk>',
    uid       => 3339,
  }
  firewall { "030 accept 12345":
    proto   => 'tcp',
    dport   => 12345,
    action  => 'accept',
  }
}
