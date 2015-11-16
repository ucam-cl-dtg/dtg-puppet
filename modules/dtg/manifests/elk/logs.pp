class dtg::elk::logs {
  class { 'dtg::apt_logstash': stage=> 'repos'}
  class { 'logstash':
    autoupgrade     => true,
    install_contrib => true,
    manage_repo     => false,
    java_install    => true,

  }

  file { '/etc/logstash/logstash.conf':
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/dtg/logstash.conf',
    notify => Service['logstash']
  }
}

class dtg::apt_logstash {
  apt::source { 'elasticsearch-logstash':
        location    => 'http://packages.elasticsearch.org/logstash/2.0/debian',
        release     => 'stable',
        repos       => 'main',
        include     =>  {'src' => false}
  }
}
