class dtg::elk::logs {
  class { 'dtg::apt_logstash': stage=> 'repos'}
  class { 'logstash':
    auto_upgrade => true,
    manage_repo  => false,
  }

  logstash::configfile { 'dtg-elk':
    source => 'puppet:///modules/dtg/logstash.conf',
  }

  file {'/local/data/logs/':
    ensure => directory,
    owner  => 'logstash',
    group  => 'logstash',
    mode   => '0744',
  }

}

class dtg::apt_logstash { # lint:ignore:autoloader_layout repo class
  apt::source { 'elasticsearch-logstash':
        location => 'http://packages.elasticsearch.org/logstash/2.0/debian',
        release  => 'stable',
        repos    => 'main',
        include  =>  {
          'src' => false
        },
        key      =>  {
          'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          'source' => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        },
  }
}
