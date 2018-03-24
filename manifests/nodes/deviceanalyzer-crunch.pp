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

node /deviceanalyzer-crunch[01234].dtg.cl.cam.ac.uk/ {
  include 'dtg::minimal'

  class {'dtg::deviceanalyzer':}

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

  # mount nas04 on startup
  file_line { 'mount nas04':
    line => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer /nas4 nfs defaults 0 0',
    path => '/etc/fstab',
  }
}

node /deviceanalyzer-crunch5/ {
  # This crunch is a LX zone running on opensolaris

  class { 'dtg::minimal': manageentropy => false, managefirewall => false }
  class {'dtg::deviceanalyzer':}

  $packagelist = ['openjdk-8-jre-headless']
  package {$packagelist:
    ensure => installed
  }

  file  { '/usr/local/distanalysis/':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'www-deviceanalyzer',
    mode   => '0755',
  }
  ->
  file {'/usr/local/distanalysis/run-distanalysis.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/deviceanalyzer/run-distanalysis.sh',
  }
  ->
  file {'/etc/init.d/distanalysis':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/deviceanalyzer/distanalysis.initd',
  }
}
