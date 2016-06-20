node 'isaac-editor.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  class {'dtg::isaac':}

  class {'apache::ubuntu': } ->
  class {'dtg::apache::raven': server_description => 'Isaac Physics'} ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::module {'ssl':} ->
  apache::site {'isaac-editor':
    source => 'puppet:///modules/dtg/apache/isaac-editor.conf',
  }->
  # download static pages from public repository
  vcsrepo { '/var/www-editor':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ucam-cl-dtg/scooter',
    owner    => 'root',
    group    => 'root'
  }

  $packages = ['rssh', 'inotify-tools', 'nodejs', 'nodejs-legacy', 'npm']
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
  nagios::monitor { 'isaac-editor':
    parents    => 'nas04',
    address    => 'isaac-editor.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  nagios::monitor { 'isaac-editor-external':
    parents                     => 'isaac-editor',
    address                     => 'editor.isaacphysics.org',
    hostgroups                  => [ 'http-servers', 'https-servers' ],
    include_standard_hostgroups => false,
  }
  munin::gatherer::async_node { 'isaac-editor': }
}

## On a new server:
##     
## cd /var/www-editor
## sudo npm install
## sudo npm install -g bower
## sudo bower --allow-root install
