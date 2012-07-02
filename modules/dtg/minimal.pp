class minimal {

  # Packages which should be installed on all servers
  $packagelist = ["vim",]
  package {
    $packagelist:
      ensure => installed
  }

  include sshd::default

  class { "etckeeper": }
  class { "ntp": servers => $ntp_servers, autoupdate => true, }
  class { "gpg": }
  class { "monkeysphere": }
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
  monkeysphere::authorized_user_ids { "root":
    user_ids => $ms_admin_user_ids
  }
}
