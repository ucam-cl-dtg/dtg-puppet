node /.*rscfl.*/ {
  include 'dtg::minimal'
  class {'distcc':
    listen_ip_range => $dtg_subnet,
    listen_on_ip    => '127.0.0.1',
  }

  $rscfl_packages = ['python-jinja2', 'systemtap', 'build-essential']
  package{$rscfl_packages:
    ensure => installed,
  }


}
