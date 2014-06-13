node /acr31-containers(-\d+)?/ {
  include 'dtg::minimal'

  # I need python3 for the lxc api, but gunicorn is not packaged for it
  # Therefore we install the python2 version of gunicorn so as to get the nice
  # debian packaging and then symlink the python3 version (from source) over the top
  $packages = ['python3-jinja2','lxc','python3-flask','gunicorn','python3-lxc']

  package{$packages:
    ensure => installed,
  }

  file{"/etc/gunicorn.d/containers":
    source => 'puppet:///modules/dtg/gunicorn/containers',
  }
    
  class {'dtg::firewall::publichttp':}

  service { "gunicorn":
    ensure => "running",
    enable => "true",
    require => Package["gunicorn"]
  }
  
  exec{"install-gunicorn-python3":
    command => "pip3 install gunicorn",
    path => "/usr/bin/:/bin",
    unless => "pip3 freeze | grep gunicorn",
  } ->
  file{"/usr/bin/gunicorn":
    ensure => link,
    source => "/usr/local/bin/gunicorn",
    notify => Service["gunicorn"],
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
