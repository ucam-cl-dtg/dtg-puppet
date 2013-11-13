# VM for sh690's Part II project
node "sh690.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  dtg::add_user { 'sh690':
    real_name => 'Simon Hollingshead',
    groups    => [ 'adm' ],
    keys      => 'Simon Hollingshead <sh690@cam.ac.uk>',
    uid       => 7634,
  } ->
  ssh_authorized_key {'sh690 key':
    ensure => present,
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABgQC0PBLKl0KmS7p/qF9U4TxllAn9BwqSDTNIIy1F8P4zzxCH9GW/64kdNvj8C5m4t7z5kOFcs+QeXy25qKV/p9TaV9/WGf/rfyJEYxjaNuqfnma5L7eJLeTyT4kROYJdY+KNu/ZQz3++EqShP4hXI01NFklJnrKQ2HZehVv0r0WPJCDWfReUg8NiJ47dEguCVSfs9aEUDDsmmQvx4VPNLjfdRrU7ROP92dxyR5JkX1UZxgoVYSckpPto48rplC1r0yYrr3QuZRNUT5K+PNoVgK/Zok6tZOPTj2BAvOm93iTQEnb5NDlbNl/GbRE/VsZeq9Fx2SPIokz2Mc2l5mi4s2IkY9kungOyDSFkr3DSwfmS11H9OR4YwJCeszbAXeoenkpVC6sKtM1Awx9UR7+SJF4J9l8zOThiX4wMnZbzyO0+2roatO867os2qILoQwgFp4Z6qa8Zq/wk5EWrMfRaNDkA7EK9mx86zVEt/n+Qt+/XIXU/mea3r7xeepF7bKpPubE=',
    user => 'sh690',
    type => 'ssh-rsa',
  }
}
if ( $::monitor ) {
  nagios::monitor { 'sh690':
    parents    => '',
    address    => 'sh690.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'sh690': }
}
