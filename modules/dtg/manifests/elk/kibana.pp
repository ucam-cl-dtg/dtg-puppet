class dtg::elk::kibana {
  dtg::apache::raven{'kibana':}
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'kibana':
    source => 'puppet:///modules/dtg/apache/kibana.conf',
  }
  class {'kibana':
    default_app_id => 'dashboard/default-dashboard',
    version => '4.1.3',
    # Override the default pid file location of /var/run/kibana.pid
    # as Kibana doesn't run as root and cannot create its pid
    # file due to permissions on /var/run
    pid_file => '/var/run/kibana/kibana.pid',
  }

}