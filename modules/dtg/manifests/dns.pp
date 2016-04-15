class dtg::dns ($dns_server = false) {
  # Run unbound and use it to serve DNS requests
  # This config doesn't allow it through the firewall which must be done elsewhere.
  if !$dns_server {
    class { 'unbound':
      interface    => ['::0','0.0.0.0'],
      access       => [ $::local_subnet, '::1', '192.168.0.0/16'],
      tcp_upstream => true,
      num_threads  => $::processorcount,
      prefetch     => 'yes',
    }
  } else {
    class { 'unbound':
      interface             => ['::0','0.0.0.0'],
      access                => [ $::local_subnet, '::1', '192.168.0.0/16'],
      tcp_upstream          => true,
      num_threads           => $::processorcount,
    # neg_cache_size        => '8m',
      key_cache_size        => '32m',
      rrset_cache_size      => '64m',
      msg_cache_size        => '32m',
      prefetch_key          => 'yes',
      prefetch              => 'yes',
      extended_statistics   => 'yes',
      statistics_cumulative => 'no',
      statistics_interval   => 0,
      control_enable        => 'yes',
    }
  }
  unbound::forward { '.':
    address => [
      '131.111.8.42', #UIS
      '131.111.12.20', #UIS # unbound round robins so we only want the ip addresses we will use
#      '128.232.1.2', #CL
#      '128.232.1.3', #CL
#      '8.8.8.8', # Google
#      '8.8.4.4',
#      '208.67.222.222', # OpenDNS
#      '208.67.220.220',
#      '128.232.1.1', # CL
      ]
  }
  # The active directory part of the CL ip address space is not properly slaved and so we need to look it up internally
  unbound::stub { '13.232.128.in-addr.arpa.': address => ['128.232.1.1', '128.232.1.2', '128.232.1.3',], insecure => true,}
  unbound::stub { '14.232.128.in-addr.arpa.': address => ['128.232.1.1', '128.232.1.2', '128.232.1.3',], insecure => true,}
  unbound::stub { '28.232.128.in-addr.arpa.': address => ['128.232.1.1', '128.232.1.2', '128.232.1.3',], insecure => true,}
  unbound::stub { '29.232.128.in-addr.arpa.': address => ['128.232.1.1', '128.232.1.2', '128.232.1.3',], insecure => true,}
  unbound::stub { '30.232.128.in-addr.arpa.': address => ['128.232.1.1', '128.232.1.2', '128.232.1.3',], insecure => true,}
  unbound::stub { '31.232.128.in-addr.arpa.': address => ['128.232.1.1', '128.232.1.2', '128.232.1.3',], insecure => true,}

  # Allow the use of private addresses as listed in http://jackdaw.cam.ac.uk/ipreg/nsconfig/sample.named.conf
  unbound::local_zone { '10.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '16.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '17.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '18.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '19.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '20.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '21.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '22.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '23.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '24.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '25.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '26.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '27.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '28.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '29.172.in-addr.arpa.': type => 'transparent'}
  unbound::local_zone { '30.172.in-addr.arpa.': type => 'transparent'}

}
