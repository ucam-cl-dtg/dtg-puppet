node /.*rscfl.*/ {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttp':}

  class {'distcc':
    listen_ip_range => $dtg_subnet,
    listen_on_ip    => '127.0.0.1',
  }

  $rscfl_packages = ['python-jinja2', 'systemtap', 'build-essential', 'cmake',
                    'clang', 'python-pip', 'ccache']
  package{$rscfl_packages:
    ensure => installed,
  }


  firewall { "032-build accept avahi udp 5353":
    proto   => 'udp',
    dport   => 5353,
    action  => 'accept',
  }

}
