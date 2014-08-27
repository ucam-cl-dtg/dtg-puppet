node /acr31-containers(-\d+)?/ {
  include 'dtg::minimal'

  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::site {'containers':
    source => 'puppet:///modules/dtg/apache/containers.conf',
  }

  class {'dtg::firewall::publichttp':}

  $packages = ['python-jinja2','lxc','python-flask']

  package{$packages:
    ensure => installed,
  }

  file{"/usr/local/containers-webapp-bare":
    ensure => directory,
    owner => acr31,
  }

  file{"/usr/local/containers-webapp":
    ensure => directory,
    owner => acr31,
  }

  dtg::add_user { 'kls82':
    real_name => 'Katie Scott',
    keys      => 'Katie Scott (ssh) <kls82@cam.ac.uk>',
    uid       => 233375, # From MCS linux `getent passwd kls82`
  }
  
}

if ( $::monitor ) {
  nagios::monitor { 'containers-1':
    parents    => 'nas04',
    address    => 'containers-1.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' , 'https-servers' ],
  }
  munin::gatherer::configure_node { 'containers-1': }
}
