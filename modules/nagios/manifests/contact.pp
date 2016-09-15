define nagios::contact (
  $contact_name,
  $contact_alias,
  $service_notification_period = '24x7',
  $service_notification_options = 'w,u,c,r',
  $service_notification_commands = 'notify-service-by-email',
  $host_notification_period = '24x7',
  $host_notification_options = 'd,r',
  $host_notification_commands = 'notify-host-by-email',
  $pager = '',
  $email = '' ) {

  file { "${nagios::params::base_dir}/conf.d/contacts/${contact_alias}.cfg":
    ensure  => present,
    content => template('nagios/contact.cfg.erb'),
    require => Package['nagios3'],
    notify  => Service['nagios3']
  }

}
