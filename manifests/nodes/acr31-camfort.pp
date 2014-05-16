node /acr31-camfort(-\d+)?/ {
  include 'dtg::minimal'

  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::site {'camfort':
    source => 'puppet:///modules/dtg/apache/camfort.conf',
  }

  class {'dtg::firewall::publichttp':}

  $packages = ['python-jinja2','python-pygments','ghc']

  package{$packages:
    ensure => installed,
  }

  file{"/usr/local/camfort-webapp-bare":
    ensure => directory,
    owner => acr31,
  }

  file{"/usr/local/camfort-webapp":
    ensure => directory,
    owner => acr31,
  }

  file{"/usr/local/camfort-webapp/workspaces":
    ensure => directory,
    owner => www-data,
  }

  # scp /home/acr31/git/camfort/camfort/camfort camfort.dtg.cl.cam.ac.uk:/usr/local/camfort-webapp
  
  
}

#if ( $::monitor ) {
#  nagios::monitor { 'camfort':
#    parents    => '',
#    address    => 'camfort.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' , 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'camfort': }
#}
