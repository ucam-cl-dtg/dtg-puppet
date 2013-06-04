
class nagios::params {
  $base_dir = "/etc/nagios3"
  $plugins_base_dir = "/etc/nagios-plugins/config"
}

# ensure base nagios configuration is in place
class nagios::server inherits nagios::params {
  $nagios_base_dir = $nagios::params::base_dir
  $nagios_plugins_base_dir = $nagios::params::plugins_base_dir

  package { [ 'nagios3', 'libxml-rss-perl' ]: 
    ensure => present, 
  }
  File { owner => 'root', group => 'root',}

  file { "$nagios_base_dir/conf.d/contacts_nagios2.cfg":
    content => template("nagios/nagios3/conf.d/contacts_nagios2.cfg.erb"),
    ensure => present,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_base_dir/conf.d/generic-host_nagios2.cfg":
    source => "puppet:///modules/nagios/nagios3/conf.d/generic-host_nagios2.cfg",
    ensure => present,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_base_dir/conf.d/services_nagios2.cfg":
    source => "puppet:///modules/nagios/nagios3/conf.d/services_nagios2.cfg",
    ensure => present,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_base_dir/commands.cfg":
    content => template("nagios/nagios3/commands.cfg.erb"),
    ensure => present,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_base_dir/conf.d/hostgroups_nagios2.cfg":
    source => "puppet:///modules/nagios/nagios3/conf.d/hostgroups_nagios2.cfg",
    ensure => present,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_base_dir/cgi.cfg":
    source => "puppet:///modules/nagios/nagios3/cgi.cfg",
    ensure => present,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_base_dir/stylesheets":
    source  => "puppet:///modules/nagios/nagios3/stylesheets",
    ensure  => directory,
    recurse => true,
    purge   => true,
    notify  => Service["nagios3"],
    require => Package["nagios3"]
  }

  # Include plugin config directory 
  file { "$nagios_plugins_base_dir/":
    source  => "puppet:///modules/nagios/nagios-plugins/config",
    ensure  => directory,
    recurse => true,
    notify  => Service["nagios3"],
    require => Package["nagios3"]
  }
  file { "$nagios_plugins_base_dir/epager.cfg":
    content => template("nagios/nagios-plugins/config/epager.cfg.erb"),
    ensure => file,
    notify => Service["nagios3"],
    require => Package["nagios3"]
  }

  # Include custom nagios commands
  file { "/usr/local/share/nagios": 
    ensure => directory,
    recurse => true,
  }

  file { "/usr/local/share/nagios/plugins": 
    ensure => directory,
    recurse => true,
    source => "puppet:///modules/nagios/nagios-plugins/plugins",
    require => [ File["/usr/local/share/nagios"],  Package["nagios3"] ]
  }
  file { "/usr/local/share/nagios/plugins/all.xml":
    ensure => file,
    content => template('nagios/nagios-plugins/plugins/all.xml.erb'),
    require => [ File["/usr/local/share/nagios"],  Package["nagios3"] ]
  }


  # this is the directory in which we publish our rss feed
  file { "/var/www/nagios": 
    ensure => directory,
    owner => "nagios",
    mode => 755
  }
  file { "/var/www/nagios/all.xml": 
    ensure => present,
    owner => "nagios",
    mode => 644,
    replace => no,
    content => template('nagios/nagios-plugins/plugins/all.xml.erb'),
  }

  # the extinfo_nagios2.cfg file defines a debian-servers host group
  # which is useless to us but will generate nagios errors because none
  # of our servers refer to it
  file { "$nagios_base_dir/conf.d/extinfo_nagios2.cfg":
    ensure => absent
  }

  file { "$nagios_base_dir/conf.d/nodes": 
    ensure  => directory,
    recurse => true, # so that nodes get deleted if deconfigured
    purge   => true,
    require => Package["nagios3"],
  }

  file { "$nagios_base_dir/conf.d/contacts": 
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package["nagios3"],
  }
  file { "$nagios_base_dir/conf.d/contactgroups": 
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package["nagios3"],
  }
  file { "$nagios_base_dir/conf.d/services": 
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package["nagios3"],
  }
  service { "nagios3":
    enable => true,
    ensure => running,
    require => Package["nagios3"],
  }

  # ensure user that will collect scp'ed logs from our nagios
  # hosts exists
  user { "nagios-collector":
    ensure => "present",
    comment => "nagios collector",
    home => "/home/nagios-collector",
    managehome => true,
    password => '*',
  }

  file { "/home/nagios-collector/server-status-reports":
    ensure => directory,
    owner => "nagios-collector",
    group => "nagios-collector",
    require => User["nagios-collector"],
  }

  file { '/home/nagios-collector/.monkeysphere/':
    ensure => directory,
    owner  => 'nagios-collector',
    group  => 'nagios-collector',
    require => User["nagios-collector"],
  }

  file { '/home/nagios-collector/.monkeysphere/authorized_user_ids':
    ensure => file,
    owner  => 'nagios-collector',
    group  => 'nagios-collector',
  }

  # Setup apache
  class { "apache": }
  apache::site { "nagios.conf":
    content => template("nagios/apache/nagios.conf.erb")
  }
  if $nagios_ssl {
    #TODO(drt24) support for cert management
    #x509::manage_cert{ "$nagios_server.crt": }
    apache::module { "ssl": }
    apache::port { 'ssl': port => 443 }
  }
  # remove the nagios file that provides access via /nagios3
  file { "/etc/apache2/conf.d/nagios3.conf":
    ensure => absent
  }
}

define nagios::contact ( 
  $contact_name, 
  $contact_alias, 
  $service_notification_period = "24x7",
  $service_notification_options = "w,u,c,r", 
  $service_notification_commands = "notify-service-by-email",
  $host_notification_period = "24x7", 
  $host_notification_options = "d,r",
  $host_notification_commands = "notify-host-by-email",
  $pager = "",
  $email = "" ) {

  file { "$nagios::params::base_dir/conf.d/contacts/${contact_alias}.cfg":
    ensure => present,
    content => template("nagios/contact.cfg.erb"),
    require => Package["nagios3"],
    notify => Service["nagios3"]
  }

}

define nagios::contactgroup(  
  $contactgroup_name, 
  $contactgroup_members, 
  $contactgroup_alias ) {

  file { "$nagios::params::base_dir/conf.d/contactgroups/${contactgroup_alias}.cfg":
    ensure => present,
    content => template("nagios/contactgroup.cfg.erb"),
    require => Package["nagios3"],
    notify => Service["nagios3"]
  }
}

define nagios::service(  
  $service_hostgroup_name, 
  $service_description, 
  $service_check_command, 
  $service_use = "generice-service", 
  $service_notification_interval = "0" ) {

  file { "$nagiosi::params::base_dir/conf.d/contactgroups/${service_host_group_name}.cfg":
    ensure => present,
    content => template("nagios/service.cfg.erb"),
    require => Package["nagios3"],
    notify => Service["nagios3"]
  }
}

define nagios::monitor (
  $address, $hostgroups, $parents, $contact_groups = "admins",
  $notification_period = "24x7", $use = "generic-host",
  $ensure = "present", $downtime = false, $include_standard_hostgroups = true ) 
{
  $host = $title

  $calculated_ensure = $ensure

  if ( $include_standard_hostgroups == true ) {
    $standard_hostgroups = [ 'ping-servers' ]# 'df-servers' not in use at present
    $assigned_hostgroups = concat($hostgroups, $standard_hostgroups)
  } else {
    $assigned_hostgroups = $hostgroups
    
  }

  file { "$nagios::params::base_dir/conf.d/nodes/$host.cfg":
    ensure => $calculated_ensure,
    content => template("nagios/server.cfg.erb"),
    require => Package["nagios3"],
    notify => Service["nagios3"]
  }

  # ensure this host is in authorized_user_ids
  file_line { $host:
    path => "/home/nagios-collector/.monkeysphere/authorized_user_ids",
    line => "root@${host}.${::org_domain}",
    require => File["/home/nagios-collector/.monkeysphere/authorized_user_ids"],
  }
}
