node /balancer(-\d+)?/ {
  include 'dtg::minimal'
  
  class {'dtg::isaac':}
  
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}

  class {'apache::ubuntu': } ->
  class {'dtg::apache::raven': server_description => 'Isaac Physics'} ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::module {'ssl':} ->
  apache::site {'balancer':
    source => 'puppet:///modules/dtg/apache/balancer.conf',
  }->
  # download static pages from public repository
  vcsrepo { '/var/www-balancer':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ucam-cl-dtg/isaac-balancer-www',
    owner    => 'root',
    group    => 'root'
  }

  $packages = ['rssh', 'inotify-tools']
  package{$packages:
    ensure => installed
  }
  ->
  file_line { 'rssh-allow-sftp':
    line => 'allowsftp',
    path => '/etc/rssh.conf',
  }
}

if ( $::monitor ) {
  nagios::monitor { 'balancer':
    parents    => 'nas04',
    address    => 'balancer.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers', 'https-servers'],
  }
  munin::gatherer::async_node { 'balancer': }
}
