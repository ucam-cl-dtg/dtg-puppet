class dtg::firewall::portforward ($src,$dest,$private) inherits dtg::firewall::default {
  firewall { "020 redirect ${src} to ${dest}":
    dport   => $src,
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => $dest,
  }
  firewall { "020 redirect ${src} to ${dest} localhost":
    dport       => $src,
    table       => 'nat',
    chain       => 'OUTPUT',
    jump        => 'REDIRECT',
    toports     => $dest,
    destination => '127.0.0.1/8',
  }
  firewall { "020 accept on ${dest}":
    proto  => 'tcp',
    dport  => $dest,
    action => 'accept',
    source => $private ? {
      true  => $::local_subnet,
      false => undef,
    }
  }
}
