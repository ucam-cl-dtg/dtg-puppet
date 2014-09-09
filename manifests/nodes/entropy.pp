node 'entropy.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of raspbian to point at
  class { 'dtg::minimal': manageapt => false, }
  class { 'dtg::entropy::host':
    certificate => '/root/puppet/ssl/stunnel.pem',
    private_key => '/root/puppet/ssl/stunnel.pem',
    ca          => '/usr/local/share/ssl/cafile',
    stage       => 'entropy-host'
  }
  # Allow connections to 7776
  class { 'dtg::firewall::entropy':}
  dtg::sshtunnelhost{ 'entropy-ssh-tunnel':
    username    => 'entropyssh',
    home        => '/home/entropyssh',
    destination => 'localhost:777',
    keys        => ['grapevine-drt24 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHt9wYQcmbir0YXnlcCFco+NRBujO2lAd47jQevej2WhpxFKXfaqL0ffBlj/1UGkVdeGXa3tAiCDIFFHdcYJtj48Cy2YVm1KOyYtlS1LMdenqpYjZgyE6JT0UCGM+6sfQCcrqkgebkyDL1mpOrnY09zhHA0PQYeqLZgC5BOIQQsMSkX1ZuYh0XJEPlScGBET9nt5yvOubDazwb6/If06vyCmjF4BN/YQgkSwwUQgG2oTBb/EUVFUzkxSYXo2XNMVLMTO94TuvksB2/SdDPffYUTPPQ/iBNASy2agZbbV1PGM24Bu6zzY8ut5cpUUBoSlje4jkt/dnQvx3AwQ4cc7rbQgkHEUVeH+hj169qW4Xp4IZkcfGDZnM0lgu9/hBk913GuVObR/qI+S+Mp2nURM4OGDRIA+HvWXx/J4wxMUkQvCMJyijzlBkhKqFSOqrBleZJtVWyw23zRcalNtu7F9yloodox4crJBxd2ysrnIlntc1upiib3pG6QbOPWauk82/wSs1iRq1de28O0lzebB4QhFd5OAYkQhazpFTI2mXatdkgz0at/KuzPEZjeDAf9rpYm70KkI3MMe5n4USgFftXeo5fspo2AtjNSsonTm9YtI3TFDi4+AQLugEHUuvfbeH0CsCWSHemzbY1RaDyoQY+9u7Wl8lOq1y+GKG/EYSC0w=='],#TODO
  }
}
if ( $::monitor ) {
  nagios::monitor { 'entropy':
    parents    => '',
    address    => 'entropy.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}
