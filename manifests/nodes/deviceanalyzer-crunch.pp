#Configuration for deviceanalyzer related stuff

$deviceanalyzer_crunch0_ips = dnsLookup('deviceanalyzer-crunch0.dtg.cl.cam.ac.uk')
$deviceanalyzer_crunch0_ip = $deviceanalyzer_crunch0_ips[0]
$deviceanalyzer_crunch1_ips = dnsLookup('deviceanalyzer-crunch1.dtg.cl.cam.ac.uk')
$deviceanalyzer_crunch1_ip = $deviceanalyzer_crunch1_ips[0]
$deviceanalyzer_crunch2_ips = dnsLookup('deviceanalyzer-crunch2.dtg.cl.cam.ac.uk')
$deviceanalyzer_crunch2_ip = $deviceanalyzer_crunch2_ips[0]
$deviceanalyzer_crunch3_ips = dnsLookup('deviceanalyzer-crunch3.dtg.cl.cam.ac.uk')
$deviceanalyzer_crunch3_ip = $deviceanalyzer_crunch3_ips[0]
$deviceanalyzer_crunch4_ips = dnsLookup('deviceanalyzer-crunch4.dtg.cl.cam.ac.uk')
$deviceanalyzer_crunch4_ip = $deviceanalyzer_crunch4_ips[0]

$deviceanalyzer_crunch_ips = "${deviceanalyzer_crunch0_ip},${deviceanalyzer_crunch1_ip},${deviceanalyzer_crunch2_ip},${deviceanalyzer_crunch3_ip},${deviceanalyzer_crunch4_ip}"

node /deviceanalyzer-crunch(\d+)?.dtg.cl.cam.ac.uk/ {
  include 'dtg::minimal'

  class {'dtg::deviceanalyzer':}

  User<|title == 'dh526' |> { groups +>[ 'adm' ]}

  firewall { '020 redirect 80 to 4567':
    dport   => '80',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => '4567',
  }

  firewall { '031-statserver accept tcp 4567 (statserver) from dtg':
    proto  => 'tcp',
    dport  => 4567,
    source => $::dtg_subnet,
    action => 'accept',
  }
  #TODO(drt24) There must be a better way of doing this iptables rules
  firewall { '031-statserver accept tcp 4567 (statserver) from grapevine':
    proto  => 'tcp',
    dport  => 4567,
    source => $::grapevine_ip,
    action => 'accept',
  }
  firewall { '031-statserver accept tcp 4567 (statserver) from earlybird':
    proto  => 'tcp',
    dport  => 4567,
    source => $::earlybird_ip,
    action => 'accept',
  }
  firewall { '032-mdns accept udp 5353 (mdns) from dtg':
    proto  => 'udp',
    dport  => 5353,
    source => $::dtg_subnet,
    action => 'accept',
  }

  # Packages which should be installed
  $packagelist = ['openjdk-8-jre-headless']
  package {
    $packagelist:
      ensure => installed
  }

#TODO(drt24) move to autofs instead
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
}
if ( $::monitor ) {
  nagios::monitor { 'deviceanalyzer-crunch0':
    parents    => 'nas04',
    address    => 'deviceanalyzer-crunch0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  munin::gatherer::configure_node { 'deviceanalyzer-crunch0': }
  munin::gatherer::configure_node { 'deviceanalyzer-crunch1': }
  munin::gatherer::configure_node { 'deviceanalyzer-crunch2': }
  munin::gatherer::configure_node { 'deviceanalyzer-crunch3': }
  munin::gatherer::configure_node { 'deviceanalyzer-crunch4': }
}
