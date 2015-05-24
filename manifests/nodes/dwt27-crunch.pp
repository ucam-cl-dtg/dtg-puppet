node 'dwt27-crunch.dtg.cl.cam.ac.uk' {
    include 'dtg::minimal'

  User<|title == dwt27 |> { groups +>[ 'adm' ]}

  $packagelist = ['python2.7', 'python-pip', 'python-virtualenv',
                  'python-numpy', 'python-scipy',
                  'libatlas3gf-base', 'libblas3gf', 'libdsdp-5.8gf',
                  'libfftw3-3', 'liblapack3gf']
  package {
    $packagelist:
        ensure => present
  }

}
