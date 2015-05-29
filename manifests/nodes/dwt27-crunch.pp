node 'dwt27-crunch.dtg.cl.cam.ac.uk' {
    include 'dtg::minimal'

  User<|title == dwt27 |> { groups +>[ 'adm' ]}

  $packagelist = ['python2.7', 'python-pip', 'python-virtualenv',
                  'python-numpy', 'python-scipy',
                  'libatlas3gf-base', 'libdsdp-5.8gf',
                  'libfftw3-3',
                  'liblapack3gf', 'liblapack-dev',
                  'libblas3gf', 'libblas-dev',
                  'python-zmq',]
# Install appropriate packages
  package {
    $packagelist:
        ensure => present
  } ->
# Install files from puppet
  file { '/home/dwt27/ipc':
    ensure => directory,
    owner => 'dwt27',
    group => 'dwt27',
    mode => '0775',
  } ->
  file { '/home/dwt27/ipc/requirements.txt':
    ensure => file,
    owner => 'dwt27',
    group => 'dwt27',
    mode => '0664',
    source => 'puppet:///modules/dtg/dwt27-crunch/requirements.txt',
  } ->
  file { '/home/dwt27/ipc/setup_venv.sh':
    ensure => file,
    owner => 'dwt27',
    group => 'dwt27',
    mode => '0775',
    source => 'puppet:///modules/dtg/dwt27-crunch/setup_venv.sh',
  } ->
  file { '/home/dwt27/ipc/start_ipc.sh',
    ensure => file,
    owner => 'dwt27',
    group => 'dwt27',
    mode => '0775',
    source => 'puppet:///modules/dtg/dwt27-crunch/start_ipc.sh',
  } ->
# Setup VirtualEnv
  exec { 'setup_venv':
    command => '/home/dwt27/ipc/setup_venv.sh',
    cwd => '/home/dwt27/ipc/',
    user => 'dwt27',
    group => 'dwt27',
    creates => '/home/dwt27/ipc/venv'
  } ->
# Setup nas04 mount
  file { '/home/dwt27/nas04':
    ensure => directory,
    owner => 'dwt27',
    group => 'dwt27',
    mode => '0775',
  } ->
  mount { 'nas04':
    name => '/home/dwt27/nas04',
    ensure => mounted,
    atboot => true,
    device => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/dwt27',
    fstype => 'nfs',
    options => 'defaults',
  }
# Setup cluster cronjob.
  cron { 'start_cluster':
    command => "/home/dwt27/ipc/start_ipc.sh"
    ensure => present,
    user => 'dwt27',
    minute => '*',
}
