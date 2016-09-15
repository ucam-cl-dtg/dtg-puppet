class dtg::maven (
  $sshmirror_keyids = []
){
  # Proxy from apache to nexus
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'maven':
    source => 'puppet:///modules/dtg/apache/maven.conf',
  }
  class {'dtg::maven::nexus':} ->
  class {'dtg::maven::sshmirror': monkeysphere_keyids => $sshmirror_keyids}
}
