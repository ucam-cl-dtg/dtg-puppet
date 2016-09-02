node /deviceanalyzer-visitor(-\w+)?/ {
  include 'dtg::minimal'


  User<|title == jk672 |> { groups +>[ 'adm' ] }

  # For DA
  package {'autofs':
    ensure => present,
  } ->
  file {'/etc/auto.mnt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'nas04   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer',
  } ->
  file_line {'mount nas':
    line => '/mnt   /etc/auto.mnt',
    path => '/etc/auto.master',
  }
  file {'/nas4':
    ensure => link,
    target => '/mnt/nas04',
  }

}

