node /acr31-camfort(-\d+)?/ {
  include 'dtg::minimal'

  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::site {'camfort':
    source => 'puppet:///modules/dtg/apache/camfort.conf',
  }

  class {'dtg::firewall::publichttp':}

  $packages = ['python-jinja2']

  package{$packages:
    ensure => installed,
  }

  file{"/usr/local/camfort-webapp":
    ensure => directory,
  }
  
}

#if ( $::monitor ) {
#  nagios::monitor { 'camfort':
#    parents    => '',
#    address    => 'camfort.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' , 'http-servers' ],
#  }
#  munin::gatherer::configure_node { 'camfort': }
#}
