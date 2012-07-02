class sshd::default(
  $max_startups = "",
  $listen_address = [ '0.0.0.0', '::' ],
  $agent_forwarding = 'no'
)
{
  class { "sshd":
    authorized_keys_file => "/var/lib/monkeysphere/authorized_keys/%u",
    max_startups => $max_startups,
    agent_forwarding => $agent_forwarding,
    listen_address => $listen_address
  }
}

class sshd::pam(
  $max_startups = "",
  $listen_address = [ '0.0.0.0', '::' ],
  $agent_forwarding = 'no'
) {
  class { "sshd": 
    authorized_keys_file => "/var/lib/monkeysphere/authorized_keys/%u",
    challenge_response_authentication => 'yes',
    password_authentication => 'yes',
    use_pam => 'yes',
    allowed_groups => "sshusers root",
    tail_additional_options => "MaxAuthTries 6",
    login_grace_time => 60,
    tcp_forwarding => yes,
    max_startups => $max_startups,
    agent_forwarding => $agent_forwarding,
  }
}

class sshd (
  $listen_address = [ '0.0.0.0', '::' ],
  $allowed_users = '',
  $allowed_groups = '', 
  $use_pam = 'no', 
  $permit_root_login = 'without-password', 
  $login_grace_time = '600', 
  $password_authentication = 'no', 
  $kerberos_authentication = 'no',
  $kerberos_orlocalpasswd = 'yes',
  $kerberos_ticketcleanup = 'yes',
  $gssapi_authentication = 'no', 
  $gssapi_cleanupcredentials = 'yes', 
  $tcp_forwarding = 'no',
  $x11_forwarding = 'no', 
  $agent_forwarding = 'no', 
  $challenge_response_authentication = 'no',
  $pubkey_authentication = 'yes', 
  $rsa_authentication = 'no',
  $strict_modes = 'yes',
  $ignore_rhosts = 'yes', 
  $rhosts_rsa_authentication = 'no',
  $hostbased_authentication = 'no', 
  $permit_empty_passwords = 'no', 
  $authorized_keys_file = "%h/.ssh/authorized_keys",
  $sftp_subsystem = '', 
  $head_additional_options = '', 
  $tail_additional_options = '', 
  $ensure_version = "present",
  $ports= [ "22" ],
  $max_startups = "" ) {

  file { 'sshd_config':
    path => '/etc/ssh/sshd_config',
    content => $template("monkeysphere/sshd/sshd.conf.erb")
    notify => Service[sshd],
    require => Package[openssh],
    owner => root, group => 0, mode => 600;
  }

  service { 'sshd':
    name => 'ssh',
    enable => true,
    ensure => running,
    hasstatus => true,
    require => File[sshd_config],
  }

  package { 'openssh':
    name => 'openssh-server',
    ensure => $ensure_version,
  }
  
  package {'openssh-client':
    ensure => installed,
  }
}
