define nagios::contactgroup(
  $contactgroup_name,
  $contactgroup_members,
  $contactgroup_alias ) {

  file { "${nagios::params::base_dir}/conf.d/contactgroups/${contactgroup_alias}.cfg":
    ensure  => present,
    content => template('nagios/contactgroup.cfg.erb'),
    require => Package['nagios3'],
    notify  => Service['nagios3']
  }
}
