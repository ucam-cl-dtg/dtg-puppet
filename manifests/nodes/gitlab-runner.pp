node /gitlab-runner(-\d+)?/ {
  include 'dtg::minimal'
  include 'docker'

  class {'dtg::scm':}

  class {'dtg::gitlab::runner::repos': stage => 'repos'}

  package {
    'gitlab-ci-multi-runner':
    ensure => installed
  }
}

class dtg::gilab::runner::repos{
  apt::source { 'gitlab-ci':
    location => 'https://packages.gitlab.com/runner/gitlab-ci-multi-runner/ubuntu/',
    repos    => 'main',
    require  => [ Package['apt-transport-https'] ],
  }
}
