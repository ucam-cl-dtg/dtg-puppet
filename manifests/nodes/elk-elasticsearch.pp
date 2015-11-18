node 'elk-elasticsearch.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class {'dtg::elk::es': }
  class {'kibana':
    port => 8080,
  }
  class { 'dtg::firewall::publichttp': }
  class { 'dtg::firewall::80to8080': }
}
