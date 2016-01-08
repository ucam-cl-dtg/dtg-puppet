class dtg::rsyslog {

  class{'rsyslog::client':
    log_templates  => [
      {
        name     => 'RFC3164fmt',
        template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',
      },
    ],
    remote_servers => [
      {
        host   => 'logs.dtg.cl.cam.ac.uk',
        format => 'RFC3164fmt',
      },
    ]
  }
}
