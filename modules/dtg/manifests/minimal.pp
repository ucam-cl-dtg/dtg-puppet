class minimal ($manageapt = true) {

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
  $packagelist = ['vim', 'screen', 'fail2ban']
  package {
    $packagelist:
      ensure => installed
  }

  include sshd::default

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
  class { 'exim::satellite':
    smarthost   => 'mail-serv.cl.cam.ac.uk',
    mail_domain => 'cl.cam.ac.uk',
  }

  class { "gpg": }
  class { "monkeysphere":
    require => Class['exim::satellite'],
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
  # Add the certifiers who sign the users
  class { "ms_id_certifiers": }
  monkeysphere::authorized_user_ids { "root":
    user_ids => $ms_admin_user_ids
  }
  # Create the admin users
  class { "admin_users":
    require => Class['exim::satellite'],
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
    require => Class['exim::satellite'],
  }
  class { 'munin::node':
    node_allow_ips => [ escapeRegexp($::munin_server_ip), '^127\.0\.0\.1$' ],
  }

}
