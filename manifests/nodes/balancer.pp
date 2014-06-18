node 'balancer.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  
  User<|title == sac92 |> { groups +>[ 'adm' ]}
  
  class {'dtg::firewall::publichttp':}

  class {'apache::ubuntu': } ->
  class {'dtg::apache::raven': server_description => 'Isaac Physics'} ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'balancer':
    source => 'puppet:///modules/dtg/apache/balancer.conf',
  }->
  # download static pages from public repository
  vcsrepo { "/var/www-balancer":
    ensure => present,
    provider => git,
    source => 'https://github.com/ucam-cl-dtg/isaac-balancer-www',
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
    hostgroups => [ 'ssh-servers' , 'http-servers' ],
  }
  munin::gatherer::configure_node { 'balancer': }
}
