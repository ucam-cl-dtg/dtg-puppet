node /acr31-containers(-\d+)?/ {
  include 'dtg::minimal'

  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::site {'containers':
    source => 'puppet:///modules/dtg/apache/containers.conf',
  }

  class {'dtg::firewall::publichttp':}

  $packages = ['python-jinja2','lxc']

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
  
}

#if ( $::monitor ) {
#  nagios::monitor { 'containers':
#    parents    => '',
#    address    => 'containers.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' , 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'containers': }
#}
