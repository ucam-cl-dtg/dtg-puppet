node /gitlab-runner(-\d+)?/ {
  include 'dtg::minimal'

  class {'dtg::scm':}

  class {'dtg::gitlab::runner::repos': stage => 'repos'}
  class {'docker': stage => 'repos'}

  package {
    'gitlab-ci-multi-runner':
    ensure => installed
  }

  file { '/tmp/Dockerfile':
    ensure => file,
    source => 'puppet://modules/dtg/images/puppet'
  }->
  docker::image { 'dtg/puppet':
    docker_file => '/tmp/Dockerfile',
    image_tag   => '16.04',
  }
}

class dtg::gitlab::runner::repos{
  apt::key { 'gitlab':
    id     => '1A4C919DB987D435939638B914219A96E15E78F4',
    source => 'https://packages.gitlab.com/gpg.key'
  } ->
  apt::source { 'gitlab-ci':
    location => 'https://packages.gitlab.com/runner/gitlab-ci-multi-runner/ubuntu/',
    repos    => 'main',
    require  => [ Package['apt-transport-https'] ],
  }
}
