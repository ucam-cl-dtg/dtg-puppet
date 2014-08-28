node /acr31-containers(-\d+)?/ {
  include 'dtg::minimal'

  service { "gunicorn":
    ensure => "running",
    enable => "true",
    require => Package["gunicorn"]
  }
  
  # I need python3 for the lxc api, but gunicorn is not packaged for it
  # Therefore we install the python2 version of gunicorn so as to get the nice
  # debian packaging and then symlink the python3 version (from source) over the top
  $packages = ['python3-jinja2','lxc','python3-flask','gunicorn','python3-lxc']

  package{$packages:
    ensure => installed,
  }
  ->
  file{["/var/www","/var/www/.config","/var/www/.config/lxc"]:
    ensure => directory,
    mode => "u+rwx",
    owner => "www-data",
  }
  ->
  file{"/var/www/.config/lxc/default.conf":
    source => 'puppet:///modules/dtg/lxc/default.conf',
  }
  ->
  exec{"install-gunicorn-python3":
    command => "pip3 install gunicorn",
    path => "/usr/bin/:/bin",
    unless => "pip3 freeze | grep gunicorn",
  }
  ->
  file{"/usr/bin/gunicorn":
    ensure => link,
    source => "/usr/local/bin/gunicorn",
    notify => Service["gunicorn"],
  }
  ->
  file{"/etc/gunicorn.d/containers":
    source => 'puppet:///modules/dtg/gunicorn/containers',
  }
  ->
  exec{"namespace-permission":
    command => "usermod -v 100000-200000 -w 100000-200000 www-data"
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

  dtg::add_user { 'kls82':
    real_name => 'Katie Scott',
    groups    => [],
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
