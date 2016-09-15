define dtg::firewall::elasticsearch ($source, $source_name) {

  require dtg::firewall::default

  firewall { "014 accept elasticsearch from ${source_name}":
    proto  => 'tcp',
    dport  => '9200',
    action => 'accept',
    source => $source,
  }
}
