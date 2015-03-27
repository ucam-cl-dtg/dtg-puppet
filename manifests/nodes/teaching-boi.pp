# vm for the British Olympiad in Informatics final

node /teaching-boi/ {
  include 'dtg::minimal'

  $packages = ['build-essential']

  class { 'dtg::firewall::publichttp': }
  class { 'dtg::firewall::80to8080':
    private => false
  }

  package{$packages:
    ensure => installed,
  }

  group { "freddie" :
  }
  ->
  user { "freddie":
    comment    => "Frederick Manners <frwm2@cam.ac.uk>",
    home       => "/home/freddie",
    shell      => '/bin/bash',
    groups     => ["adm","freddie"],
    membership => 'minimum',
    password   => '*',
  }
  ->
  file { "/home/freddie/":
    ensure  => directory,
    owner   => "freddie",
    group   => "freddie",
    mode    => '0755',
  }
  ->
  file {"/home/freddie/.ssh/":
    ensure => directory,
    owner => "freddie",
    group => "freddie",
    mode => '0700',
  }
  ->
  ssh_authorized_key {'freddie key 1':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCivusLFTIrpAd4lbGnH9hT82GUS+MQSEBqo3YxUpJs4+u9xA1eXiTEY2kemzJWtwXUCMKyn48rQDgfQtjiE46PHWUX9ax0zGIEahbvwkXvDhwu70vtnfZEl2q3p5/PGdF88TsfdD909wpitHimnJqTFU9QhAHf68L9UtPjOoxAtWmq17RwNeOYVnP2yhpv1E+ir6pi9uNnt14xlW1DdWJRINlPcuerQuGAifEpgfNZ5qnNUnKTAkiY1fQd4ReY2zp8izh0kh2eXGUOQ+CSySBy6SBG/WPc+gonXTf7VMO8KpUE1YQbpHb9izfkKRF5SgZBUtYGpvgKqAFDxWfLHkuV",
    user   => 'freddie',
    type   => 'ssh-rsa',
    name   => 'freddie@langerhans',
  }
} 

if ( $::monitor ) {
  munin::gatherer::configure_node { 'teaching-boi': }
}
