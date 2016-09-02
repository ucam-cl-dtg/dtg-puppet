define nagios::hostgroup(
  $hostgroup_name,
  $hostgroup_alias,
  $hostgroup_members = '') {

  concat::fragment { "nagios_hostgroup_${name}":
    target  => "${nagios::params::base_dir}/conf.d/hostgroups_nagios2.cfg",
    content => template('nagios/nagios3/conf.d/hostgroups.cfg.erb'),
    order   => '10',
    require => Package['nagios3'],
    notify  => Service['nagios3']
  }
}
