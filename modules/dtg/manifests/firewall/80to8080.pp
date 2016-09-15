class dtg::firewall::80to8080 ($private = true) inherits dtg::firewall::default {
  firewall { '020 redirect 80 to 8080':
    dport   => '80',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => '8080',
  }
  firewall { '020 redirect 80 to 8080 localhost':
    dport       => '80',
    table       => 'nat',
    chain       => 'OUTPUT',
    jump        => 'REDIRECT',
    toports     => '8080',
    destination => '127.0.0.1/8',
  }
  firewall { '020 accept on 8080':
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
    source => $private ? {
      true  => $::local_subnet,
      false => undef,
    }
  }
}
