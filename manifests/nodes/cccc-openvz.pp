node 'cccc-openvz.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class { 'apt::source::openvz':
    stage => 'repos'
  }
  $packagelist = ['linux-image-openvz-amd64', 'upstart-sysv', 'vzctl']
  package {$packagelist: ensure => installed,}
  ->
  virt { 'test-1':
    ensure      => 'running',
    os_template => 'ubuntu-15.10',
    virt_type   => 'openvz',
    autoboot    => 'true',
    provider    => 'openvz',
    interfaces  => ['eth0'],
    ipaddr      => ['192.168.2.1'],
    diskspace   => '4G:4G',
  }
  firewall { '033 nat for openvz containers':
    table    => 'nat',
    chain    => 'POSTROUTING',
    outiface => 'eth0',
    jump     => 'MASQUERADE',
  }
  firewall { '034 forward to openvz containers':
    chain    => 'FORWARD',
    iniface  => 'eth0',
    outiface => 'venet0',
    state    => ['RELATED', 'ESTABLISHED'],
    action   => 'accept',
  }
  firewall { '034 forward from openvz containers':
    chain    => 'FORWARD',
    iniface  => 'venet0',
    outiface => 'eth0',
    action   => 'accept',
  }
  firewall { '030-dns accept tcp 53 (dns) from openvz containers':
    proto  => 'tcp',
    dport  => 53,
    source => '192.168.0.0/16',
    action => 'accept',
  }
  firewall { '031-dns accept udp 53 (dns) from openvz containers':
    proto  => 'udp',
    dport  => 53,
    source => '192.168.0.0/16',
    action => 'accept',
  }

}
class apt::source::openvz {
  apt::source{ 'openvz':
    location => 'http://download.openvz.org/debian',
    release  => 'wheezy',
    repos    => 'main',
    key      => {
      'id'     => 'DA2458173935F9DE9B76BA7547B5DBAB0FCA9BAC',
      'source' => 'http://download.openvz.org/debian/archive.key',
    }
  }
}
/* Not yet production
if ( $::monitor ) {
  nagios::monitor { 'HOSTNAME':
    parents    => '',
    address    => 'HOSTNAME.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'HOSTNAME': }
}
*/
