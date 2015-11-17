class dtg::elk::es {

  class { 'elasticsearch':
    autoupgrade => true,
    java_install => true,
    datadir => '/local/data/elk-es',
    manage_repo => false
  }

  elasticsearch::instance { 'es-logs-0': }

  dtg::firewall::elasticsearch{'es-logs':
    source => dnsLookup('logs.dtg.cl.cam.ac.uk'),
    source_name => 'logstash',
  }

}
