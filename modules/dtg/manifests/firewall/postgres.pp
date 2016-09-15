define dtg::firewall::postgres ($source, $source_name) {

  require dtg::firewall::default

  firewall { "014 accept postgres requests from ${source_name}":
    proto  => 'tcp',
    dport  => '5432',
    action => 'accept',
    source => $source,
  }
}
