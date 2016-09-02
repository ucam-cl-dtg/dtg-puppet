define nagios::monitor (
$address, $hostgroups, $parents, $contact_groups = 'admins',
$notification_period = '24x7', $use = 'generic-host',
$ensure = 'present', $downtime = false, $include_standard_hostgroups = true )
{
$host = $title

$calculated_ensure = $ensure

if ( $include_standard_hostgroups == true ) {
  $standard_hostgroups = [ 'ping-servers' ]# 'df-servers' not in use at present
  $assigned_hostgroups = concat($hostgroups, $standard_hostgroups)
} else {
  $assigned_hostgroups = $hostgroups
  
}

file { "${nagios::params::base_dir}/conf.d/nodes/${host}.cfg":
  ensure  => $calculated_ensure,
  content => template('nagios/server.cfg.erb'),
  require => Package['nagios3'],
  notify  => Service['nagios3']
}

# ensure this host is in authorized_user_ids
file_line { $host:
  path    => '/home/nagios-collector/.monkeysphere/authorized_user_ids',
  line    => "root@${host}.${::org_domain}",
  require => File['/home/nagios-collector/.monkeysphere/authorized_user_ids'],
}
}
