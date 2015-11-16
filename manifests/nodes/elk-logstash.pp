node 'elk-logstash.dtg.cl.cam.ac.uk' {
  class { 'dtg::minimal': }
  class { 'dtg::firewall::rsyslog': }
  class { 'dtg::elk::logs': }
}
