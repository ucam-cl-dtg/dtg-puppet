node /^acr31-pottery/ {
  include 'dtg::minimal'

  class {'dtg::pottery::docker': stage => 'repos' }
  
  file{'/local/data/docker':
    ensure => directory,
    owner  => 'root'
  }
  ->
  package{docker-ce:
    ensure => installed,
  }
  ->
  class { 'docker':
    tcp_bind                    => 'tcp://127.0.0.1:2375',
    socket_bind                 => 'unix:///var/run/docker.sock',
    root_dir                    => '/local/data/docker',
    use_upstream_package_source => false,
    manage_package              => false,
  }
  ->
  exec {'add-www-data-to-docker-group':
    unless  => "/bin/grep -q '^docker:\\S*www-data' /etc/group",
    command => '/usr/sbin/usermod -aG docker www-data',
  }
  ->
  docker::image { 'ubuntu':
    image_tag => '16.04'
  }
    
  class {'dtg::pottery::gitlab': stage => 'repos' }
  class {'dtg::firewall::publichttps':} ->
  class {'dtg::firewall::portforward': src=>'443',dest=>'8443',private=>false}

  $packages = ['openjdk-8-jdk','libapr1','tomcat8','gitlab-ce']

  package{$packages:
    ensure => installed,
  }
}

class dtg::pottery::gitlab { # lint:ignore:autoloader_layout repo class
  apt::source{ 'gitlab':
    location => 'https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu/',
    release  => 'xenial',
    repos    => 'main',
    key      => {
      'id'     => '1A4C919DB987D435939638B914219A96E15E78F4',
      'source' => 'https://packages.gitlab.com/gpg.key',
    }
  }
}

class dtg::pottery::docker { # lint:ignore:autoloader_layout repo class
  apt::source{ 'docker':
    location => 'https://download.docker.com/linux/ubuntu',
    release  => 'xenial',
    repos    => 'stable',
    key      => {
      'id'     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
      'source' => 'https://download.docker.com/linux/ubuntu/gpg',
    }
  }
}
