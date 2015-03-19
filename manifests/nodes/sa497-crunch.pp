node /sa497-crunch(-\d+)?/ {
    include 'dtg::minimal'

  User<|title == sa497 |> { groups +>[ 'adm' ]}

  # Packages which should be installed
  $packagelist = [ 'autofs']
  package {
    $packagelist:
      ensure => installed
  } ->

  file {'/etc/auto.mnt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'nas04   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/rwandadataset ',
  } ->

  file_line {'mount nas':
    line => '/mnt   /etc/auto.mnt',
    path => '/etc/auto.master',
  }
}
