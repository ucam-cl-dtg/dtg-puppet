node 'crucible.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == sac92 |> { groups +>[ 'adm' ] }

  package {['openjdk-7-jdk']:
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
 user { "crucible":
    ensure => present,
    comment => "Crucible user",
    home => "/local/crucible_home"
  }
 ->
 file { "/local/crucible_home":
    ensure => "directory",
    owner  => "crucible",
    group  => "crucible",
    mode   => 755,
 }

}
