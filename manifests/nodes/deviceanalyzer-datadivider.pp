
node 'deviceanalyzer-datadivider.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == 'dh526' |> { groups +>[ 'adm' ]}

  # open up ports 80,443
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}

  # Packages which should be installed
  $packagelist = ['openjdk-8-jdk', 'nginx', 'autofs']
  package {
    $packagelist:
      ensure => installed
  } ->
  file {'/etc/auto.mnt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'nas04   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer-datadivider
nas01   nas01.dtg.cl.cam.ac.uk:/data/deviceanalyzer-datadivider
deviceanalyzer   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer'
  } ->
  file_line {'mount nas':
    line => '/mnt   /etc/auto.mnt',
    path => '/etc/auto.master',
  }

}

if ( $::monitor ) {
  nagios::monitor { 'dh526-datadivider':
    parents    => '',
    address    => 'dh526-datadivider.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::async_node { 'dh526-datadivider': }
}
