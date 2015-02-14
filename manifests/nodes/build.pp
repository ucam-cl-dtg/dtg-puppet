node /build-(\d+)?/ {
  include 'dtg::minimal'
  class {'distcc':
    listen_ip_range => $dtg_subnet,
    listen_on_ip    => "",
  }


  firewall { "031-build accept tcp 3632":
    proto   => 'tcp',
    dport   => 3632,
    action  => 'accept',
  }
}
