class minimal {

  # Manage apt sources lists - TODO(drt24) this probably wants to be factored out
  #  Use puppet to manage sources.list but allow manual stuff inside sources.list.d
  class { 'apt': purge_sources_list => true }
  # Include main repository
  class { 'apt::source': location => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/ubuntu/', repos => 'main restricted universe multiverse'}
  # Security updates
  class { 'apt::source': location => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/ubuntu/', release => "${::lsbdistcodename}-security", repos => 'main restricted universe multiverse'}
  # Bugfix updates
  class { 'apt::source': location => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/ubuntu/', release => "${::lsbdistcodename}-updates", repos => 'main restricted universe multiverse'}

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
