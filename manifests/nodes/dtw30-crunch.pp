#Configuration for deviceanalyzer related stuff

$dtw30_crunch0_ips = dnsLookup('dtw30-crunch0.dtg.cl.cam.ac.uk')
$dtw30_crunch0_ip = $dtw30_crunch0_ips[0]
$dtw30_crunch1_ips = dnsLookup('dtw30-crunch1.dtg.cl.cam.ac.uk')
$dtw30_crunch1_ip = $dtw30_crunch1_ips[0]
$dtw30_crunch2_ips = dnsLookup('dtw30-crunch2.dtg.cl.cam.ac.uk')
$dtw30_crunch2_ip = $dtw30_crunch2_ips[0]
$dtw30_crunch3_ips = dnsLookup('dtw30-crunch3.dtg.cl.cam.ac.uk')
$dtw30_crunch3_ip = $dtw30_crunch3_ips[0]
$dtw30_crunch4_ips = dnsLookup('dtw30-crunch4.dtg.cl.cam.ac.uk')
$dtw30_crunch4_ip = $dtw30_crunch4_ips[0]

$dtw30_crunch_ips = "${dtw30_crunch0_ip},${dtw30_crunch1_ip},${dtw30_crunch2_ip},${dtw30_crunch3_ip},${dtw30_crunch4_ip}"

node /dtw30-crunch(\d+)?.dtg.cl.cam.ac.uk/ {
  include 'dtg::minimal'

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
  $packagelist = ['openjdk-7-jre-headless']
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
  nagios::monitor { 'dtw30-crunch0':
    parents    => 'nas04',
    address    => 'dtw30-crunch0.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],#TODO(drt24) monitor the statsserver
  }
  munin::gatherer::configure_node { 'dtw30-crunch0': }
}
