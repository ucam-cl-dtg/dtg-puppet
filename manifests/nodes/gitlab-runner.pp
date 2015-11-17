node /gitlab-runner(-\d+)?/ {
  include 'dtg::minimal'
  include 'docker'

  class {'dtg::scm':}

  package {
    'apt-transport-https':
    ensure => installed,
  } ->
  apt::source { 'gitlab-ci':
    location => 'https://packages.gitlab.com/runner/gitlab-ci-multi-runner/ubuntu/',
    repos    => 'main',
  } ->
  package {
    'gitlab-ci-multi-runner':
    ensure => installed
  }
}


