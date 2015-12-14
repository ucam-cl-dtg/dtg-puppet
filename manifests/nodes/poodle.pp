node 'poodle.dtg.cl.cam.ac.uk' {
  # A small physical server to provide some backup services and to provide the entropy service
  class { 'dtg::minimal': }
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
    keys        => [
        'grapevine-drt24 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHt9wYQcmbir0YXnlcCFco+NRBujO2lAd47jQevej2WhpxFKXfaqL0ffBlj/1UGkVdeGXa3tAiCDIFFHdcYJtj48Cy2YVm1KOyYtlS1LMdenqpYjZgyE6JT0UCGM+6sfQCcrqkgebkyDL1mpOrnY09zhHA0PQYeqLZgC5BOIQQsMSkX1ZuYh0XJEPlScGBET9nt5yvOubDazwb6/If06vyCmjF4BN/YQgkSwwUQgG2oTBb/EUVFUzkxSYXo2XNMVLMTO94TuvksB2/SdDPffYUTPPQ/iBNASy2agZbbV1PGM24Bu6zzY8ut5cpUUBoSlje4jkt/dnQvx3AwQ4cc7rbQgkHEUVeH+hj169qW4Xp4IZkcfGDZnM0lgu9/hBk913GuVObR/qI+S+Mp2nURM4OGDRIA+HvWXx/J4wxMUkQvCMJyijzlBkhKqFSOqrBleZJtVWyw23zRcalNtu7F9yloodox4crJBxd2ysrnIlntc1upiib3pG6QbOPWauk82/wSs1iRq1de28O0lzebB4QhFd5OAYkQhazpFTI2mXatdkgz0at/KuzPEZjeDAf9rpYm70KkI3MMe5n4USgFftXeo5fspo2AtjNSsonTm9YtI3TFDi4+AQLugEHUuvfbeH0CsCWSHemzbY1RaDyoQY+9u7Wl8lOq1y+GKG/EYSC0w=='
      , 'carmel-entropyssh ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0VOSV7w5eDGpD2FFY+qVaEpw7Ly+HcFfFKuiNhiiJ+JSynsEgDW559DZ0xCD7++PWH7ByEylOPeVMN0Or8KXXFX7Ziw4Sw0ALktwJkMMvu6m5BpkK7PMnz0DVvpJwfgJQe2Pzon03T5MJ33q9yyELMnHZDL2mPp56PJAbgQiVTbNJEvXP+ntIxnnyBzX6k4s9KRDZ5X3SNAG6UP058xs5Ffv4Wb11IdQ4CjVR821RcF1+9kdDcRVduDfKo/YymSAO7QZwIeWrKW7+rcY88t3/kLdiSgjj1OqVY7kKymRetcu9b7l3/9SOOVoax8c8lRh2l1Qx/dS+NF9xS15DOGIFaQT+uy7w4AR1+I04E32dtoLx85q7kVvQFLizA4Hy8LKP5s1I6e3DMCJE8/DjlmewSctvyYB/f+mG2q2lOr7dMoPr9oBvFub/dRENZF7FHQg8o7w2feHDX+KjlKIYJmrkTLZlkVs9li39F7KOuy0R44C4BJIgKLK3ydCPshQfHb1ciybtXa6clDrnDXbCTt31ImfYYf8+Mstr1PBO2ykvRiR2p4Nwv6UgBeg+0aaVQf8gWN2AUMwNuH/DWQF8JWjSSk8A8qQxfEReB4CVr5ehhplwYuzeeyy8QLXO22Ib5jNIpSlffc7PuVYbmHtdwxu+rubDa/kG168o0XkbC4TYFw=='],
  }
}
if ( $::monitor ) {
  nagios::monitor { 'poodle':
    parents    => 'se18-r8-sw1',
    address    => 'poodle.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'entropy-servers', 'dns-servers'],
  }
  nagios::monitor { 'entropy-poodle':
    parents    => 'poodle',
    address    => 'entropy.dtg.cl.cam.ac.uk',
    hostgroups => [ 'entropy-servers'],
  }
  nagios::monitor { 'dns-1':
    parents    => 'poodle',
    address    => 'dns-1.dtg.cl.cam.ac.uk',
    hostgroups => [ 'dns-servers'],
  }
  munin::gatherer::configure_node { 'poodle': }
}
