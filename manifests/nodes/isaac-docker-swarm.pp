node /isaac-\d+/ {
  include 'dtg::minimal'

  class {'dtg::isaac':}

  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}

  $packages = ['htop']
  package{$packages:
    ensure => installed
  }
  
  # dbbackup user
  user {'isaac':
    ensure => present,
    shell  => '/bin/bash',
    home   => '/usr/share/isaac'
  }
}