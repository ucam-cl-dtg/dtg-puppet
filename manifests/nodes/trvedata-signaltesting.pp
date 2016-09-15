# VM for the TRVE Data Project to test Signal related issues 
node 'trvedata-signaltesting.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  ssh_authorized_key {'jdw74 key':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDF6Bw1ogRxz8gXbqP2E2Wu7VeM+aFMqgF6m8KtZcU45sJkmZkNSt55uhcDaeW1b+He8p73uKyt0+QmMt+h916hDGx+NM+ZftQS1mC1gAwfqg8hro3CzbXgeULCjZS+ozt7Iqj7I1ONG6PSffr0keJ2xoVfQ8KhCyK4pjODq4aHICFQ1lG9+2xMjHni07Urbv5RJq+NXhhxo3/rgyV4mEig9Qzis6p6vTCYSCcAM7hllLD1PdifU87utV2/KKVRKrzEKXz/cYjfO25MeMf85CLKsG9qrIA+1Mk7+o8ZMYIce0pAreluD+HLJnNzC+EzQetlhfRQzxHdei1YEJdAZ8Hv',
    user   => 'jdw74',
    type   => 'ssh-rsa',
  }

  dtg::add_user { 'jdw74':
    real_name      => 'James Wood',
    groups         => ['adm'],
    keys           => ['James Wood <jdw74@cam.ac.uk>'],
    uid            => 238847,
    user_whitelist => $user_whitelist,

  }
}
