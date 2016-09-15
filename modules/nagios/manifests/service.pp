define nagios::service(
  $service_hostgroup_name,
  $service_description,
  $service_check_command,
  $service_use = 'generic-service',
  $service_notification_interval = '0' ) {



  concat::fragment { "nagios_service_${name}":
    target  => "${nagios::params::base_dir}/conf.d/services_nagios2.cfg",
    content => template('nagios/services.cfg.erb'),
    order   => '10',
    require => Package['nagios3'],
    notify  => Service['nagios3']
  }
}
