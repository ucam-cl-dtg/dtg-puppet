node /acr31-containers(-\d+)?/ {
  include 'dtg::minimal'

  $packages = ['python-jinja2','lxc','python-flask','libapache2-mod-fastcgi','gunicorn']

  package{$packages:
    ensure => installed,
  }

  file{"/etc/gunicorn.d/containers":
    source => 'puppet:///modules/dtg/gunicorn/containers',
  }
    
  class {'dtg::firewall::publichttp':}


  
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
