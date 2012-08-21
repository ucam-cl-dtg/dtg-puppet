class dtg::maven {
  # Proxy from apache to nexus
  apache::site {'maven':
    source => 'puppet:///modules/dtg/apache/maven.conf',
  }
  # TODO(drt24) actually install nexus
}
