node 'crucible.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == sac92 |> { groups +>[ 'adm' ] }
  class {'dtg::isaac':}

  package {['openjdk-8-jdk', 'unzip']:
    ensure => installed
  }
  ->
  file { '/usr/lib/jvm/default-java':
    ensure => 'link',
    target => '/usr/lib/jvm/java-1.7.0-openjdk-amd64',
  }
  ->
  file_line { 'java_home':
    path => '/etc/environment',
    line => 'JAVA_HOME="/usr/lib/jvm/default-java"',
  }
  ->
  user { 'crucible':
    ensure  => present,
    comment => 'Crucible user',
    home    => '/usr/share/crucible_home'
  }
  ->
  file { '/usr/share/crucible_home':
    ensure => 'directory',
    owner  => 'crucible',
    group  => 'crucible',
    mode   => '0755',
  }
  ->
  wget::fetch { 'wget-fetch-crucible':
    source      => 'http://www.atlassian.com/software/crucible/downloads/binary/crucible-3.4.4.zip',
    destination => '/tmp/crucible.zip',
    redownload  => false,
    timeout     => 60,
  }
  ->
  exec { 'unpack crucible':
    command => 'sudo -H -u crucible unzip -u /tmp/crucible.zip',
    cwd     => '/usr/share/crucible_home',
  }
  ->
  file { '/var/lib/crucible_data':
    ensure => 'directory',
    owner  => 'crucible',
    group  => 'crucible',
    mode   => '0755'
  }
  ->
  file_line { 'fisheye_crucible_instance_location':
      path => '/etc/environment',
      line => 'FISHEYE_INST="/var/lib/crucible_data"',
  }
# only required on initial installation
#  ->
#  file { '/var/lib/crucible_data/config.xml':
#    ensure => present,
#    source => '/usr/share/crucible_home/fecru-3.4.4/config.xml',
#    owner  => 'crucible',
#    group  => 'crucible',
#    mode   => '0755',
#  }

  firewall { '020 redirect 80 to 8060':
    dport   => '80',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => '8060',
  }
  ->
  firewall { '020 accept on 8060':
    proto  => 'tcp',
    dport  => '8060',
    action => 'accept',
    source => undef
  }
  ->
  class {'dtg::firewall::publichttp':}
}

