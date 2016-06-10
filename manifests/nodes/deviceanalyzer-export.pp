# DeviceAnalyzer running in a LX domain on SmartOS

# This node is used for running a batch mode distanalysis for generating exports

node 'deviceanalyzer-export' {
  class { 'dtg::minimal': manageentropy => false, managefirewall => false }

  class {'dtg::deviceanalyzer':}

  $packagelist = ['openjdk-8-jre-headless']
  package {$packagelist:
    ensure => installed
  }

  file {'/var/cache/distanalysis/':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'www-deviceanalyzer',
    mode   => '0755'
  }
  ->
  file {'/var/cache/distanalysis/analysed':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'www-deviceanalyzer',
    mode   => '0755'
  }
  
  file  { '/usr/local/distanalysis/':
    ensure => directory,
    owner  => 'www-deviceanalyzer',
    group  => 'www-deviceanalyzer',
    mode   => '0755',
  }
  ->
  file {'/usr/local/distanalysis/run-distanalysis-export.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/deviceanalyzer/run-distanalysis-export.sh',
  }
}

