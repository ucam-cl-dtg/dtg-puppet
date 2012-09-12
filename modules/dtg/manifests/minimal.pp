class dtg::minimal ($manageapt = true) {

  # Set up the repositories, get some entropy then do everything else
  #  entropy needs to start being provided before it is consumed
  stage {'entropy': before => Stage['main'] }
  stage {'entropy-host': before => Stage['entropy'] }
  stage {'repos': before => Stage['entropy-host'] }
  # Manage apt sources lists
  if $manageapt {
    class { 'aptrepository':
      repository => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/ubuntu/',
      stage => 'repos'
    }
  }

  # Packages which should be installed on all servers
  $packagelist = ['vim', 'screen', 'fail2ban', 'curl', 'tar', 'runit', 'apg']
  package {
    $packagelist:
      ensure => installed
  }

  include 'monkeysphere::sshd::default'

  class { "etckeeper": }
  class { "ntp": servers => $ntp_servers, autoupdate => true, }
  # Get entropy then do gpg and then monkeysphere
  class { 'dtg::entropy': stage => 'entropy-host' }
  class { 'dtg::entropy::client':
    cafile  => '/usr/local/share/ssl/cafile',
    host_address => 'entropy.dtg.cl.cam.ac.uk',
    stage => 'entropy',
    require => File['/usr/local/share/ssl/cafile'],
  }

  # Make it possible to send email (if correct from address is used)
  class { 'dtg::email': }

  class { "gpg": }
  class { "monkeysphere":
    require => Class['dtg::email'],
  }
  # create hourly cron job to update users authorized_user_id files
  $ms_min = random_number(60) 
  file { "/etc/cron.d/monkeysphere":
    content => template('monkeysphere/monkeysphere.erb'),
    owner => root,
    group => root,
    replace => no,
    mode => 0644
  }
  # ensure our ssh key is imported into the monkeysphere
  monkeysphere::import_key { "main": }
  monkeysphere::publish_server_keys { 'main':}
  gpg::private_key {'root':
    homedir => '/root',
    passphrase => $::ms_gpg_passphrase,
  }
  monkeysphere::auth_capable_user {'root':
    passphrase => $::ms_gpg_passphrase,
    home       => '/root',
    require    => Gpg::Private_key['root'],
  }
  monkeysphere::ssh_agent { 'root':
    passphrase => $::ms_gpg_passphrase,
    require    => Monkeysphere::Auth_capable_user['root'],
  }
  # Add the certifiers who sign the users
  class { "ms_id_certifiers": }
  monkeysphere::authorized_user_ids { "root":
    user_ids => $ms_admin_user_ids
  }
  file { "/usr/local/sbin/setuserpassword":
    ensure  => file,
    mode    => 755,
    owner   => root,
    group   => root,
    source  => "puppet:///modules/dtg/sbin/setuserpassword",
    require => Package['apg'],
  }
  # Create the admin users
  class { "admin_users":
    require => Class['dtg::email'],
  }
  # Allow admin users to push puppet config
  group { "adm": ensure => present }
  sudoers::allowed_command{ "puppet":
    command          => '/usr/bin/puppet',
    group            => 'adm',
    require_password => false,
    comment          => 'Allow members of the admin group to use puppet as root without requiring a password - so that they can update the puppet repositories and hence trigger the hooks',
  }
  # Make admin users admin users
  sudoers::allowed_command{ 'adm':
    command => 'ALL',
    group   => 'adm',
    comment => 'Allow members of the admin group to use password sudo to get root',
  }
  class { 'dtg::unattendedupgrades':
    unattended_upgrade_notify_emailaddress => $::unattended_upgrade_notify_emailaddress,
    require => Class['dtg::email'],
  }
  class { 'munin::node':
    node_allow_ips => [ escapeRegexp($::munin_server_ip), '^127\.0\.0\.1$' ],
  }
  # Include default firewall rules
  class { 'dtg::firewall': }
  sshkey {'localhost':
    ensure => present,
    host_aliases => [$::fqdn, $::hostname],
    key    => $::sshrsakey,
    type   => 'rsa',
  }

  # Keep stuff put in at bootstrap up to date
  file {'/etc/puppet':
    ensure => directory,
    owner  => 'root',
    group  => 'adm',
    mode   => '2775',
  }
  file {'/etc/puppet-bare':
    ensure => directory,
    owner  => 'root',
    group  => 'adm',
    mode   => '2775',
  }
  file {'/etc/puppet-bare/hooks/post-update':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0775',
    source => 'puppet:///modules/dtg/post-update.hook',
  }
}
