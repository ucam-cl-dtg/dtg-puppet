class dtg::puppy_deploy_key {
  class { 'ssh::client':
    storeconfigs_enabled => false,
    options              => {
      'Host gitlab.dtg.cl.cam.ac.uk' => {
        'IdentityFile' => '/etc/ssh/puppy-deploy-public',
      },
    },
  }

  file {'/etc/ssh/puppy-deploy-public':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0640',
    source => 'puppet:///modules/dtg/files/ssh/puppy-deploy-public',
  }

  file {'/etc/ssh/puppy-deploy-public.pub':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0644',
    source => 'puppet:///modules/dtg/files/ssh/puppy-deploy-public.pub',
  }
}

