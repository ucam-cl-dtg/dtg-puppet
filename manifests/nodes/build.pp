node /build-(\d+)?/ {
  include 'dtg::minimal'
  class {'distcc': 
    listen_ip_range => $dtg_subnet,
    listen_on_ip => $::ipaddress,
  }
}