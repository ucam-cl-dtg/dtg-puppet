node /acr31-apjava/ {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttp':}
  ->
  firewall {'060 accept all 8080':
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
  }

  $packages = ['openjdk-8-jdk','tomcat8']
  package{$packages:
    ensure => installed,
  }
  
}

if ( $::monitor ) {
  nagios::monitor { 'acr31-apjava':
    parents    => 'nas04',
    address    => 'acr31-apjava.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  
  munin::gatherer::configure_node { 'acr31-apjava': }
}
