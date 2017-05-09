class dtg::puppy_deploy_key {
  # SSH Private Deploy Key
  # Best practices forbid ssh private keys in version control
  # However in this case it has been deemed acceptable as all
  # repositories that the key will grant access to should be ones
  # that may be publically read anyway. The deploy key on gitlab
  # is appropriatly flagged with a bold warning that the key may
  # be publically accessible.
  file {'/etc/ssh/puppy-deploy-public':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0600',
    source => 'puppet:///modules/dtg/files/ssh/puppy-deploy-public',
  }

  file {'/etc/ssh/puppy-deploy-public.pub':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0644',
    source => 'puppet:///modules/dtg/files/ssh/puppy-deploy-public.pub',
  }

  ::ssh::client::config::user { 'root':
    ensure              => present,
    user_home_dir       => '/root',
    manage_user_ssh_dir => false,
    options             => {
      'Host gitlab.dtg.cl.cam.ac.uk' => {
        'IdentityFile' => '/etc/ssh/puppy-deploy-public',
      },
    },
  }
}

