class dtg::puppy_deploy_key {
  # SSH Private Deploy Key
  # Best practices forbid ssh private keys in version control
  # However in this case it is acceptable as all repositories
  # that the key will grant access to should be ones that may
  # be publicly read anyway. The deploy key on gitlab is
  # appropriately flagged with a bold warning that the key is
  # publicly accessible.
  file {'/root/.ssh':
    ensure => directory,
    owner  => 'root',
    mode   => '0600',
  }

  file {'/root/.ssh/puppy-deploy-public':
    ensure  => file,
    owner   => 'root',
    group   => 'adm',
    mode    => '0600',
    source  => 'puppet:///modules/dtg/files/ssh/puppy-deploy-public',
    require => [ File['/root/.ssh'] ],
  }

  file {'/root/.ssh/puppy-deploy-public.pub':
    ensure  => file,
    owner   => 'root',
    group   => 'adm',
    mode    => '0644',
    source  => 'puppet:///modules/dtg/files/ssh/puppy-deploy-public.pub',
    require => [ File['/root/.ssh'] ],
  }

  ::ssh::client::config::user { 'root':
    ensure              => present,
    user_home_dir       => '/root',
    manage_user_ssh_dir => false,
    options             => {
      'Host gitlab.dtg.cl.cam.ac.uk' => {
        'IdentityFile' => '/root/.ssh/puppy-deploy-public',
      },
    },
    require             => [ File['/root/.ssh/puppy-deploy-public']],
  }
}

