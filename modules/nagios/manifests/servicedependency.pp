define nagios::servicedependency(
  $sd_hostgroup_name,
  $sd_service_description,
  $sd_dependent_service_description,
  $sd_execution_failure_criteria = 'w,u,c,p',
  $sd_notification_failure_criteria = 'w,u,c' ) {



  concat::fragment { "nagios_servicedependency_${name}":
    target  => "${nagios::params::base_dir}/conf.d/services_nagios2.cfg",
    content => template('nagios/servicedependencies.cfg.erb'),
    order   => '20',
    require => Package['nagios3'],
    notify  => Service['nagios3']
  }
}
