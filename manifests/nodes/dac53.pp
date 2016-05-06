# VM for dac53's Mphil project
node 'dac53.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  ssh_authorized_key {'dac53 key':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDM299YV9WPk2Tfvajj79gDPG09BEJ2B1vBpEBPGG2ri1erlHYfN7UCHwGQITh1adBxt0CzuDaTU6AtTxohWvRNvUj8hjVOCjeIb0093Hva0q2yHBNAJ/Ac2bAfDNn28p6DZYTS6nYRxqBNAJbbku3AL9Hvr7YxLLJpYphCT9ro02WuXjOsSM3ixLFnNRDzPxrXm1Uibbhe3e0Ri/3jZToA8zinB5Po5UCIXpnT7phBAyysIZ6NHe0y8ExD5j544l/WZ84QiG/r1vBR9ROgciZ+vTgFCU0j42DiPIwgBuoj2i0/7kLvgSMxrhx4Se0D1iT4xDcTqgTB9AOkjVoreMYJ',
    user   => 'dac53',
    type   => 'ssh-rsa',
  }
  User<|title == dac53 |> { groups +>[ 'adm' ] }
  # mount nas02 on startup
  file_line { 'mount nas02':
    line => 'nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer /nas2 nfs defaults 0 0',
    path => '/etc/fstab',
  }

  # mount nas04 on startup
  file_line { 'mount nas04':
    line => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer-backup /nas4 nfs defaults 0 0',
    path => '/etc/fstab',
  }
  
}
