class minimal {

  # Manage apt sources lists
  class { 'aptrepository': repository => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/ubuntu/' }

  # Packages which should be installed on all servers
  $packagelist = ["vim", "screen",]
  package {
    $packagelist:
      ensure => installed
  }

  include sshd::default

  class { "etckeeper": }
  class { "ntp": servers => $ntp_servers, autoupdate => true, }
  # Get entropy then do gpg and then monkeysphere
  class { "ekeyd::client": host => 'entropy.dtg.cl.cam.ac.uk', port => '7776', } -> class { "gpg": } -> class { "monkeysphere": }
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
}
