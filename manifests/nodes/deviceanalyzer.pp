#Configuration for deviceanalyzer related stuff

$deviceanalyzer_ips = dnsLookup('deviceanalyzer.dtg.cl.cam.ac.uk')
$deviceanalyzer_ip = $deviceanalyzer_ips[0]

node 'deviceanalyzer.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  # open up ports 80,443,2468
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  firewall { "030-xmlsocketserver accept tcp 2468 (xmlsocketserver) from anywhere":
    proto   => 'tcp',
    dport   => 2468,
    action  => 'accept',
  }

  # Packages which should be installed
  $packagelist = ['openjdk-7-jdk', 'jetty8', 'nginx']
  package {
    $packagelist:
      ensure => installed
  }

  # mount nas02 on startup
  file_line { 'mount nas02':
  	line => 'nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer /nas2 nfs defaults 0 0',
  	path => '/etc/fstab', 
  }

  # mount nas04 on startup
  file_line { 'mount nas04':
  	line => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer /nas4 nfs defaults 0 0',
  	path => '/etc/fstab', 
  }

  # set up nginx and jetty config
  file {'/etc/nginx/sites-enabled/default':
    ensure => absent,
  }
  file {'/etc/nginx/sites-enabled/deviceanalyzer.nginx.conf':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode  => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/deviceanalyzer.nginx.conf',
  }
  file {'/etc/default/jetty8':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode  => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/jetty8',
  }
  file {'/etc/init.d/xmlsocketserver':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode  => '0755',
    source => 'puppet:///modules/dtg/deviceanalyzer/xmlsocketserver.initd',
  }
  file {'/etc/network/interfaces':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode  => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/interfaces',
  }

  # ensure webapps directory is writeable by the non-standard 'www-data' user
  file { '/var/lib/jetty8/webapps':
  	ensure => directory,
  	owner => 'www-data',
    group => 'www-data',
    mode  => '0755',
  }
}
if ( $::monitor ) {
  nagios::monitor { 'hound4':
    parents    => '',
    address    => 'hound4.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  nagios::monitor { 'deviceanalyzer':
    parents    => ['nas04', 'nas02'],
    address    => 'deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers', 'ssh-servers' ],
  }
  nagios::monitor { 'secure.deviceanalyzer':
    parents    => 'deviceanalyzer',
    address    => 'secure.deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
  nagios::monitor { 'upload.deviceanalyzer':
    parents    => 'deviceanalyzer',
    address    => 'upload.deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }
  nagios::monitor { 'dtw30-crunch0':
    parents    => 'nas04',
    address    => 'dtw30-crunch0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],#TODO(drt24) monitor the statsserver
  }
  munin::gatherer::configure_node { 'hound4': }
  munin::gatherer::configure_node { 'deviceanalyzer': }
  munin::gatherer::configure_node { 'dtw30-crunch0': }
}
